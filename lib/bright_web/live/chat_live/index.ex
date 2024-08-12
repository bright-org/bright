defmodule BrightWeb.ChatLive.Index do
  use BrightWeb, :live_view

  alias Bright.Chats
  alias Bright.Accounts
  alias Bright.Recruits
  alias Bright.Teams
  alias Bright.Utils.GoogleCloud.Storage

  import BrightWeb.ChatLive.ChatComponents
  import BrightWeb.BrightModalComponents, only: [bright_modal: 1]

  @max_entries 4
  @filter_types [
    %{name: "（条件を選択してください）", value: :not_completed_interview},
    %{name: "面談打診中", value: :waiting_decision},
    %{name: "面談確定待ち", value: :consume_interview},
    %{name: "面談確定", value: :ongoing_interview},
    %{name: "選考中", value: :waiting_recruit_decision},
    %{name: "面談キャンセル", value: :cancel_interview},
    %{name: "（すべて）", value: :recruit}
  ]

  @default_filter_type "not_completed_interview"

  @impl true
  def mount(_params, _session, %{assigns: %{current_user: user}} = socket) do
    socket
    |> assign(:open_confirm_interview, false)
    |> assign(:open_cancel_interview, false)
    |> assign(:open_create_coordination, false)
    |> assign(:open_edit_interview, false)
    |> assign(:sender_icon_path, user.user_profile.icon_file_path)
    |> assign(:images_error, "")
    |> assign(:files_error, "")
    |> assign(:preview, nil)
    |> assign(:team_members, Teams.list_user_ids_related_team_by_user(user))
    |> assign(:filter_types, @filter_types)
    |> allow_upload(:images,
      accept: ~w(.jpg .jpeg .png),
      max_file_size: 2_000_000,
      max_entries: @max_entries
    )
    |> allow_upload(:files, accept: :any, max_file_size: 2_000_000, max_entries: @max_entries)
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :recruit, %{"id" => chat_id} = params) do
    select_filter_type = get_select_filter_type(params)

    user = socket.assigns.current_user

    chat = Chats.get_chat!(chat_id)

    chat = get_chat_with_messages!(chat, user.id)

    Chats.subscribe(chat.id)

    Chats.read_chat!(chat.id, user.id)

    socket
    |> assign(:page_title, "面談チャット")
    |> assign(:select_filter_type, select_filter_type)
    |> assign(:chats, Chats.list_chats(user.id, select_filter_type))
    |> assign(:chat, chat)
    |> assign(:messages, chat.messages)
    |> assign(:message, nil)
    |> push_event("scroll_bottom", %{})
  end

  defp apply_action(socket, :recruit, params) do
    select_filter_type = get_select_filter_type(params)
    user = socket.assigns.current_user

    socket
    |> assign(:page_title, "面談チャット")
    |> assign(:select_filter_type, select_filter_type)
    |> assign(:chats, Chats.list_chats(user.id, select_filter_type))
    |> assign(:chat, nil)
    |> assign(:messages, [])
    |> assign(:message, nil)
  end

  @impl true
  def handle_event("validate", %{"_target" => [target]} = params, socket)
      when target in ["images", "files"] do
    target = String.to_atom(target)
    error_target = String.to_atom("#{target}_error")
    uploads = Map.get(socket.assigns.uploads, target)

    socket =
      case uploads.errors do
        [] ->
          assign(socket, error_target, "")

        [{_ref, :too_many_files}] ->
          entry = List.last(uploads.entries)

          socket
          |> assign(error_target, :too_many_files)
          |> cancel_upload(target, entry.ref)

        [{_ref, error}] ->
          assign(socket, error_target, error)
      end

    socket =
      uploads.entries
      |> Enum.filter(&(&1.valid? == false && &1.cancelled? == false))
      |> Enum.reduce(socket, fn entry, socket -> cancel_upload(socket, target, entry.ref) end)

    {:noreply, assign(socket, :message, params["message"])}
  end

  def handle_event("validate", params, socket) do
    {:noreply, assign(socket, :message, params["message"])}
  end

  def handle_event("cancel-upload", %{"ref" => ref, "target" => target}, socket) do
    socket
    |> cancel_upload(String.to_atom(target), ref)
    |> assign(String.to_atom("#{target}_error"), "")
    |> then(&{:noreply, &1})
  end

  def handle_event("send", %{"message" => ""}, socket) do
    {:noreply, socket}
  end

  def handle_event(
        "send",
        %{"message" => text},
        %{assigns: %{current_user: user, chat: chat}} = socket
      ) do
    case Chats.create_message(gen_params(socket.assigns, text), socket) do
      {:ok, _message} ->
        Chats.update_chat(chat, %{updated_at: NaiveDateTime.utc_now()})
        send_new_message_notification_mails(chat, user)

        socket
        |> assign(:message, nil)
        |> assign(:images_error, "")
        |> assign(:files_error, "")
        |> then(&{:noreply, &1})

      {:error, %Ecto.Changeset{}} ->
        {:noreply, socket}
    end
  end

  def handle_event("open_confirm_interview", _params, socket) do
    {:noreply, assign(socket, :open_confirm_interview, true)}
  end

  def handle_event("cancel_interview", _params, socket) do
    {:noreply, assign(socket, :open_cancel_interview, true)}
  end

  def handle_event("open_edit_interview", _params, socket) do
    {:noreply, assign(socket, :open_edit_interview, true)}
  end

  def handle_event("open_create_coordination", _params, socket) do
    {:noreply, assign(socket, :open_create_coordination, true)}
  end

  def handle_event("close_chat", _params, socket) do
    {:ok, _chat} =
      Recruits.update_interview(socket.assigns.chat.interview, %{status: :close_chat})

    socket
    |> put_flash(:info, "チャットを閉じました")
    |> redirect(to: ~p"/recruits/chats")
    |> then(&{:noreply, &1})
  end

  def handle_event("preview", %{"preview" => url}, socket) do
    {:noreply, assign(socket, :preview, url)}
  end

  def handle_event("close_preview", _params, socket) do
    {:noreply, assign(socket, :preview, nil)}
  end

  def handle_event("select_filter_type", %{"select_filter_type" => select_filter_type}, socket) do
    socket =
      socket
      |> redirect(to: ~p"/recruits/chats?select_filter_type=#{select_filter_type}")

    {:noreply, socket}
  end

  def handle_event(
        "delete_message",
        %{"message_id" => message_id},
        %{assigns: %{chat: chat}} = socket
      ) do
    message =
      socket.assigns.messages
      |> Enum.find(&(&1.id == message_id))

    Chats.delete_message_with_broadcast!(message)
    Chats.update_chat(chat, %{updated_at: NaiveDateTime.utc_now()})

    {:noreply, socket}
  end

  @impl true
  def handle_info({:send_message, message}, socket) do
    assign_new_chat(socket, message)
    |> push_event("scroll_bottom", %{})
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_info({:delete_message, message}, socket) do
    assign_new_chat(socket, message)
    |> then(&{:noreply, &1})
  end

  defp assign_new_chat(
         %{assigns: %{current_user: user, select_filter_type: select_filter_type}} = socket,
         message
       ) do
    chat = Chats.get_chat!(message.chat_id)
    chat = get_chat_with_messages!(chat, user.id)

    Chats.read_chat!(chat.id, user.id)

    socket
    |> assign(:chats, Chats.list_chats(user.id, select_filter_type))
    |> assign(:chat, chat)
    |> assign(:messages, chat.messages)
  end

  @doc """
  チャットのステータスを表示する
  get_display_name差はフィルターで集約している内容も追加している
  """
  def get_status(:dismiss_interview), do: "面談キャンセル"
  def get_status(:cancel_interview), do: "面談キャンセル"
  def get_status(:ongoing_interview), do: "面談確定"
  def get_status(:cancel_coordination), do: "不採用"
  def get_status(:cancel_recruiter), do: "不採用"
  def get_status(:cancel_candidates), do: "採用辞退"
  def get_status(value), do: Gettext.gettext(BrightWeb.Gettext, to_string(value))

  defp gen_params(%{current_user: user, chat: chat, uploads: uploads}, text) do
    images = Enum.map(uploads.images.entries, &Chats.ChatFile.build(:images, &1))
    files = Enum.map(uploads.files.entries, &Chats.ChatFile.build(:files, &1))
    %{text: text, chat_id: chat.id, sender_user_id: user.id, files: images ++ files}
  end

  defp send_new_message_notification_mails(chat, sender) do
    chat.users
    |> Enum.each(fn chat_user ->
      if chat_user.id != sender.id do
        Chats.deliver_new_message_notification_email_instructions(
          chat_user,
          chat,
          &url(~p"/recruits/chats/#{&1}")
        )
      end
    end)
  end

  defp error_to_string(:too_large), do: translate_error({"The file is too large", []})
  defp error_to_string(:too_many_files), do: translate_error({"Too many files are uploaded", []})

  defp error_to_string(:not_accepted),
    do: translate_error({"You have selected an unacceptable file type", []})

  defp error_to_string(_), do: ""

  defp get_select_filter_type(params) do
    value =
      params
      |> Map.get("select_filter_type", @default_filter_type)
      |> String.to_atom()

    @filter_types
    |> Enum.find(Enum.at(@filter_types, 0), &(&1.value == value))
    |> Map.get(:value)
  end

  defp is_interview?(%{coordination_id: nil, employment_id: nil} = _chat), do: true
  defp is_interview?(_), do: false

  defp get_chat_with_messages!(%{coordination_id: nil, employment_id: nil} = chat, user_id),
    do: Chats.get_chat_with_messages_and_interview!(chat.id, user_id)

  defp get_chat_with_messages!(%{employment_id: nil} = chat, user_id),
    do: Chats.get_chat_with_messages_and_coordination!(chat.id, user_id)

  defp get_chat_with_messages!(chat, user_id),
    do: Chats.get_chat_with_messages_and_employment!(chat.id, user_id)
end

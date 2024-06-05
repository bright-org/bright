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
    %{name: "採用選考中", value: :completed_interview},
    %{name: "面談キャンセル", value: :cancel_interview},
    %{name: "（すべて）", value: :recruit}
  ]

  @default_filter_type "not_completed_interview"

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex bg-white ml-1 h-[calc(100vh-56px)] pb-16 lg:pb-0">
      <div class={"flex flex-col w-screen lg:w-[560px] border-r-2 overflow-y-auto #{if @chat != nil, do: "hidden lg:flex"}"}>
       <.filter_type_select_dropdown_menue select_filter_type={@select_filter_type}/>
        <%= if Enum.count(@chats) == 0 do %>
          <p class="text-xl lg:p-4">
            チャット対象者がいません<br /> 「スキル検索」の「面談の打診」や<br /> 「チームスキル分析」の「1on1に誘う」<br /> からチャット開始してください
          </p>
        <% else %>
          <%= for chat <- @chats do %>
            <.chat_list
              chat={chat}
              selected_chat={@chat}
              user_id={@current_user.id}
              member_ids={@team_members}
              select_filter_type={@select_filter_type}
            />
          <% end %>
        <% end %>
      </div>

      <div
        :if={@chat}
        id="messages"
        class="w-full px-5 flex flex-col justify-between overflow-y-auto"
        phx-hook="Chat"
      >
        <div class="flex flex-col mt-5">
          <p class="lg:ml-12 text-xl mb-2">※メールアドレスや電話番号等の個人情報は送らないでください</p>
          <p class="lg:ml-12 text-xl mb-8">※面談日時およびその重複は管理対象外ですので、別途管理を行ってください</p>
          <div
            :if={@current_user.id == @chat.owner_user_id && Accounts.hr_enabled?(@current_user.id)}
            class="lg:ml-12 text-xl"
          >
            <%= if @chat.interview.status == :consume_interview do %>
              <p>本チャットで面談対象者と連絡を取り、「面談調整の確認」ボタンを押してください</p>
              <p class="mt-2 text-attention-600">面談確定するとチャットに（担当者から面談が確定されました）が自動投入され、メールも送信されます</p>
            <% end %>
          </div>

          <%= for message <- @messages do %>
            <.message
              chat={@chat}
              message={message}
              current_user={@current_user}
              sender_icon_path={@sender_icon_path}
            />
          <% end %>
        </div>
        <div :if={@chat} class="py-5 sticky bottom-0 bg-white">
          <form id="message_form" phx-submit="send" phx-change="validate">
            <div class="flex pb-2">
              <div class="w-[50px] flex justify-center flex-col items-center">
                <.user_icon path={@sender_icon_path} />
              </div>
              <div class="w-full">
                <.input
                  type="textarea"
                  class="w-full min-h-1 outline-none p-2"
                  placeholder="メッセージを入力"
                  autocapitalize="none"
                  name="message"
                  value={@message}
                />
              </div>
            </div>
            <hr class="pb-1 border-brightGray-100" />
            <div class="flex justify-end gap-x-4 pt-2 pb-2 w-full content-start">
              <div class="mr-auto">
                <div class="flex">
                  <label for={@uploads.images.ref} class="cursor-pointer hover:opacity-70">
                    <.live_file_input upload={@uploads.images} class="hidden" />
                    <span class="material-icons-outlined !text-4xl">add_photo_alternate</span>
                  </label>
                  <label for={@uploads.files.ref} class="cursor-pointer hover:opacity-70">
                    <.live_file_input upload={@uploads.files} class="hidden" />
                    <span class="material-symbols-outlined !text-4xl">add_box</span>
                  </label>
                </div>
                <div class="flex gap-x-12">
                  <div>
                    <%= for entry <- @uploads.images.entries do %>
                      <div class="flex flex-col w-20">
                        <button
                          type="button"
                          class="self-end z-[4] -mr-1"
                          phx-click="cancel-upload"
                          phx-value-ref={entry.ref}
                          phx-value-target="images"
                          aria-label="cancel"
                        >
                          <span class="material-icons bg-attention-300 !text-sm rounded-full !inline-flex w-4 h-4 !items-center !justify-center text-white">
                            close
                          </span>
                        </button>
                        <.live_img_preview
                          entry={entry}
                          class="object-cover cursor-pointer hover:opacity-70 h-20 w-20 -mt-4"
                        />
                      </div>
                    <% end %>
                    <p class="mt-2 text-attention-600"><%= error_to_string(@images_error) %></p>
                  </div>
                  <div>
                    <%= for entry <- @uploads.files.entries do %>
                      <div class="flex w-full">
                        <p><%= entry.client_name %></p>
                        <button
                          type="button"
                          class="self-end z-[4] ml-4"
                          phx-click="cancel-upload"
                          phx-value-ref={entry.ref}
                          phx-value-target="files"
                          aria-label="cancel"
                        >
                          <span class="material-icons bg-attention-300 !text-sm rounded-full !inline-flex w-4 h-4 !items-center !justify-center text-white">
                            close
                          </span>
                        </button>
                      </div>
                    <% end %>
                    <p class="mt-2 text-attention-600"><%= error_to_string(@files_error) %></p>
                  </div>
                </div>
              </div>
              <div class="flex flex-col lg:flex-row gap-2">
                <div class="order-3 lg:order-1">
                  <.link navigate={~p"/recruits/chats"}>
                    <button
                      type="button"
                      class="text-sm font-bold ml-auto px-3 py-3 rounded border bg-white w-24 lg:hidden"
                    >
                      一覧に戻る
                    </button>
                  </.link>
                </div>
                <div
                  :if={
                    @chat.owner_user_id == @current_user.id and Accounts.hr_enabled?(@current_user.id)
                  }
                  class="order-2 flex justify-end"
                >
                  <%= if @chat.interview.status == :one_on_one do %>
                    <button
                      class="text-sm font-bold ml-auto px-2 py-3 rounded border bg-base text-white w-56"
                      type="button"
                      phx-click={JS.push("open_edit_interview")}
                    >
                      面談の打診
                    </button>
                  <% end %>

                  <%= if @chat.interview.status == :consume_interview do %>
                    <button
                      class="text-sm font-bold ml-auto px-2 py-3 rounded border bg-base text-white w-56"
                      type="button"
                      phx-click={
                        JS.push("open_confirm_interview") |> JS.show(to: "interview-confirm-modal")
                      }
                    >
                      面談調整の確認
                    </button>
                  <% end %>
                  <%= if @chat.interview.status == :ongoing_interview do %>
                    <button
                      class="text-sm font-bold ml-auto px-2 py-3 rounded border bg-base text-white w-56"
                      type="button"
                      phx-click={
                        JS.push("open_create_coordination")
                        |> JS.show(to: "coordination-create-modal")
                      }
                    >
                      採用選考の確認
                    </button>
                  <% end %>
                </div>
                <div class="order-1 lg:order-3 flex justify-end lg:ml-2">
                  <button
                    type="submit"
                    class="text-sm font-bold px-2 py-3 rounded border bg-base text-white w-56 h-12"
                  >
                    メッセージを送る
                  </button>
                </div>
              </div>
            </div>
          </form>
        </div>
      </div>

      <.bright_modal
        :if={@chat && @open_confirm_interview}
        id="interview-confirm-modal"
        show
        on_cancel={JS.navigate(~p"/recruits/chats/#{@chat.id}")}
      >
        <.live_component
          module={BrightWeb.RecruitInterviewLive.ConfirmComponent}
          id="interview_confirm_modal"
          title={@page_title}
          action={@live_action}
          interview_id={@chat.relation_id}
          current_user={@current_user}
          patch={~p"/recruits/chats/#{@chat.id}"}
        />
      </.bright_modal>

      <.bright_modal
        :if={@chat && @open_cancel_interview}
        id="interview-cancel-modal"
        show
        on_cancel={JS.navigate(~p"/recruits/chats/#{@chat.id}")}
      >
        <.live_component
          module={BrightWeb.RecruitInterviewLive.CancelComponent}
          id="interview_cancel_modal"
          title={@page_title}
          action={@live_action}
          interview_id={@chat.relation_id}
          current_user={@current_user}
          patch={~p"/recruits/chats"}
          return_to={~p"/recruits/chats/#{@chat.id}"}
        />
      </.bright_modal>

      <.bright_modal
        :if={@chat && @open_create_coordination}
        id="coordination-create-modal"
        show
        on_cancel={JS.navigate(~p"/recruits/chats/#{@chat.id}")}
      >
        <.live_component
          :if={@current_user}
          id="coordination_modal"
          module={BrightWeb.RecruitCoordinationLive.CreateComponent}
          current_user={@current_user}
          interview_id={@chat.relation_id}
          patch={~p"/recruits/chats/#{@chat.id}"}
        />
      </.bright_modal>

      <.bright_modal
        :if={@chat && @open_edit_interview}
        id="interview-edit-modal"
        show
        on_cancel={JS.navigate(~p"/recruits/chats/#{@chat.id}")}
      >
        <.live_component
          :if={@current_user}
          id="interview_edit_modal"
          module={BrightWeb.RecruitInterviewLive.Edit1on1InterviewComponent}
          current_user={@current_user}
          interview_id={@chat.relation_id}
          patch={~p"/recruits/chats/#{@chat.id}"}
        />
      </.bright_modal>

      <.modal :if={!is_nil(@preview)} id="preview" show on_cancel={JS.push("close_preview")}>
        <img src={Storage.public_url(@preview)} />
        <a href={Storage.public_url(@preview)} target="_blank" rel="noopener">
          <.button class="mt-4">Dwonload</.button>
        </a>
      </.modal>
    </div>
    """
  end

  attr :select_filter_type, :any, required: true

  def filter_type_select_dropdown_menue(assigns) do
    assigns = assigns |> assign(filter_types: @filter_types)

    ~H"""
    <div
      id="filter_select"
      phx-hook="Dropdown"
      data-dropdown-offset-skidding="0"
      data-dropdown-placement="bottom"
    >
      <bottun
        class="text-left flex items-center text-base p-1 rounded border border-brightGray-100 bg-white  w-[220px] hover:bg-brightGray-50 dropdownTrigger"
        type="button"
      >
        <%= get_display_name(@select_filter_type) %>
      </bottun>
      <!-- menue list-->
      <div
        class="dropdownTarget z-30 hidden bg-white rounded-sm shadow static w-[220px]"
      >
        <ul>
          <%= for filter_type <- @filter_types do %>
            <li
              class="text-left flex items-center text-base hover:bg-brightGray-50 p-1 bg-white w-full"
              phx-click="select_filter_type"
              phx-value-select_filter_type={filter_type.value}
            >
              <%= filter_type.name %>
            </li>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

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
    chat = Chats.get_chat_with_messages_and_interview!(chat_id, user.id)
    Phoenix.PubSub.subscribe(Bright.PubSub, "chat:#{chat.id}")

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

  @impl true
  def handle_info(
        {:send_message, message},
        %{assigns: %{current_user: user}} = socket
      ) do
    chat = Chats.get_chat_with_messages_and_interview!(message.chat_id, user.id)

    Chats.read_chat!(chat.id, user.id)

    socket
    |> assign(:chats, Chats.list_chats(user.id, :recruit))
    |> assign(:chat, chat)
    |> assign(:messages, chat.messages)
    |> push_event("scroll_bottom", %{})
    |> then(&{:noreply, &1})
  end

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

  defp get_display_name(value) do
    filter_type =
      @filter_types
      |> Enum.find(fn x ->
        x.value == value
      end)

    filter_type.name
  end

  defp get_select_filter_type(params) do
    params
    |> Map.get("select_filter_type", @default_filter_type)
    |> String.to_atom()
  end
end

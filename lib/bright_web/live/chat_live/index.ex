defmodule BrightWeb.ChatLive.Index do
  use BrightWeb, :live_view

  alias Bright.Chats
  alias Bright.Accounts
  alias Bright.Recruits

  import BrightWeb.ChatLive.ChatComponents
  import BrightWeb.BrightModalComponents, only: [bright_modal: 1]

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex bg-white ml-1 h-[calc(100vh-56px)] pb-16 lg:pb-0">
      <div class={"flex flex-col w-screen lg:w-[560px] border-r-2 overflow-y-auto #{if @chat != nil, do: "hidden lg:flex"}"}>
        <%= if Enum.count(@chats) == 0 do %>
          <p class="text-xl lg:p-4">
            チャット対象者がいません<br />
            「スキル検索」の「面談の打診」や<br />
            「チームスキル分析」の「1on1に誘う」<br/>
            からチャット開始してください
          </p>
        <% else %>
          <%= for chat <- @chats do %>
            <.chat_list chat={chat} selected_chat={@chat} user_id={@current_user.id}/>
          <% end %>
        <% end %>
      </div>

      <div :if={@chat} class="w-full px-5 flex flex-col justify-between overflow-y-auto">
        <div class="flex flex-col mt-5" >
          <p class="lg:ml-12 text-xl mb-2">※メールアドレスや電話番号等の個人情報は送らないでください</p>
          <p class="lg:ml-12 text-xl mb-8">※面談日時およびその重複は管理対象外ですので、別途管理を行ってください</p>
          <div :if={@current_user.id == @chat.owner_user_id && Accounts.hr_enabled?(@current_user.id) } class="lg:ml-12 text-xl">
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
          <form phx-submit="send">
            <div class="flex pb-2">
              <div class="w-[50px] flex justify-center flex-col items-center">
                <.user_icon path={@sender_icon_path} />
              </div>
              <div class="w-full">
                <textarea
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
                <button>
                  <span class="material-icons-outlined !text-4xl opacity-50">add_photo_alternate</span>
                </button>
                <button>
                  <span class="material-symbols-outlined !text-4xl opacity-50">add_box</span>
                </button>
              </div>

              <div class="flex flex-col lg:flex-row gap-2">
                <div class="order-3 lg:order-1">
                  <.link navigate={~p"/recruits/chats"}>
                    <button type="button" class="text-sm font-bold ml-auto px-3 py-3 rounded border bg-white w-24 lg:hidden">
                      一覧に戻る
                    </button>
                  </.link>
                  <.link phx-click="close_chat" data-confirm="このチャットを閉じますか？">
                    <button type="button" class="text-sm font-bold lg:mr-2 px-2 py-3 rounded border bg-white w-36 lg:w-56">
                      チャットを閉じる
                    </button>
                  </.link>
                </div>
                <div
                  :if={@chat.owner_user_id == @current_user.id and Accounts.hr_enabled?(@current_user.id)}
                  class="order-2 flex justify-end"
                >
                  <%= if @chat.interview.status == :consume_interview do %>
                    <button
                      class="text-sm font-bold ml-auto px-2 py-3 rounded border bg-base text-white w-56"
                      type="button"
                      phx-click={JS.push("open_confirm_interview") |> JS.show(to: "interview-confirm-modal")}
                    >
                      面談調整の確認
                    </button>
                  <% end %>
                  <%= if @chat.interview.status == :ongoing_interview do %>
                    <button
                      class="text-sm font-bold ml-auto px-2 py-3 rounded border bg-base text-white w-56"
                      type="button"
                      phx-click={JS.push("open_create_coordination") |> JS.show(to: "coordination-create-modal")}
                    >
                      採用選考の確認
                    </button>
                  <% end %>
                </div>
                <div class="order-1 lg:order-3 flex justify-end lg:ml-2">
                  <button
                    type="submit"
                    class="text-sm font-bold px-2 py-3 rounded border bg-base text-white w-56"
                  >
                    メッセージを送る
                  </button>
                </div>
              </div>
            </div>
          </form>
        </div>
      </div>

      <.bright_modal :if={@chat && @open_confirm_interview} id="interview-confirm-modal" show on_cancel={JS.navigate(~p"/recruits/chats/#{@chat.id}")}>
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

      <.bright_modal :if={@chat && @open_cancel_interview}  id="interview-cancel-modal" show on_cancel={JS.navigate(~p"/recruits/chats/#{@chat.id}")}>
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

      <.bright_modal :if={@chat && @open_create_coordination}  id="coordination-create-modal" show on_cancel={JS.navigate(~p"/recruits/chats/#{@chat.id}")}>
        <.live_component
          id="coordination_modal"
          module={BrightWeb.RecruitCoordinationLive.CreateComponent}
          current_user={@current_user}
          interview_id={@chat.relation_id}
          :if={@current_user}
          patch={~p"/recruits/chats/#{@chat.id}"}
        />
      </.bright_modal>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, %{assigns: %{current_user: user}} = socket) do
    socket
    |> assign(:open_confirm_interview, false)
    |> assign(:open_cancel_interview, false)
    |> assign(:open_create_coordination, false)
    |> assign(:sender_icon_path, user.user_profile.icon_file_path)
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :recruit, %{"id" => chat_id}) do
    user = socket.assigns.current_user
    chat = Chats.get_chat_with_messages_and_interview!(chat_id, user.id)
    Phoenix.PubSub.subscribe(Bright.PubSub, "chat:#{chat.id}")

    socket
    |> assign(:page_title, "面談チャット")
    |> assign(:chats, Chats.list_chats(user.id, :recruit))
    |> assign(:chat, chat)
    |> assign(:messages, chat.messages)
    |> assign(:message, nil)
  end

  defp apply_action(socket, :recruit, _params) do
    user = socket.assigns.current_user

    socket
    |> assign(:page_title, "面談チャット")
    |> assign(:chats, Chats.list_chats(user.id, :recruit))
    |> assign(:chat, nil)
    |> assign(:messages, [])
    |> assign(:message, nil)
  end

  @impl true
  def handle_event("send", %{"message" => ""}, socket) do
    {:noreply, socket}
  end

  def handle_event(
        "send",
        %{"message" => text},
        %{assigns: %{current_user: user, chat: chat}} = socket
      ) do
    case Chats.create_message(%{text: text, chat_id: chat.id, sender_user_id: user.id}) do
      {:ok, _message} ->
        Chats.update_chat(chat, %{updated_at: NaiveDateTime.utc_now()})
        send_new_message_notification_mails(chat, user)
        {:noreply, socket}

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

  @impl true
  def handle_info(
        {:send_message, message},
        %{assigns: %{current_user: user}} = socket
      ) do
    chat = Chats.get_chat_with_messages_and_interview!(message.chat_id, user.id)

    socket
    |> assign(:chats, Chats.list_chats(user.id, :recruit))
    |> assign(:messages, chat.messages)
    |> then(&{:noreply, &1})
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
end

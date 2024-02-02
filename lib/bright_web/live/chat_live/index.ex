defmodule BrightWeb.ChatLive.Index do
  use BrightWeb, :live_view

  alias Bright.Chats
  alias Bright.Accounts
  alias Bright.Recruits
  alias Bright.Recruits.Interview
  alias Bright.UserProfiles
  alias BrightWeb.CardLive.CardListComponents

  import BrightWeb.BrightModalComponents, only: [bright_modal: 1]

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex bg-white ml-1 h-[calc(100vh-56px)]">
      <div class={"flex flex-col w-screen lg:w-[560px] border-r-2 overflow-y-auto #{if @chat != nil, do: "hidden lg:flex"}"}>
        <%= if Enum.count(@chats) == 0 do %>
          <p class="text-xl lg:p-4">
            チャット対象者がいません<br />
            「スキル検索」の「面談調整」や<br />
            「チームスキル分析」の「1on1に誘う」<br/>
            からチャット開始してください
          </p>
        <% else %>
          <%= for chat <- @chats do %>
            <.link
              class={"flex py-4 px-4 justify-center items-center border-b-2 cursor-pointer #{if @chat != nil && chat.id == @chat.id, do: "border-l-4 border-l-blue-400"}"}
              patch={~p"/recruits/chats/#{chat.id}"}
            >
              <% path = if Interview.anon?(chat.interview), do: nil, else: chat.interview.candidates_user_icon %>
              <img
                src={UserProfiles.icon_url(path)}
                class="object-cover h-10 w-10 rounded-full mr-2"
                alt=""
              />
              <div class="w-full flex justify-between p-1">
                <div class="flex-1 mr-2 lg:truncate lg:text-xl">
                <span><%= if chat.interview.skill_panel_name == nil , do: "スキルパネルデータなし", else: chat.interview.skill_panel_name %></span>
                <br />
                <span class="text-brightGray-300">
                <%= NaiveDateTime.to_date(chat.interview.inserted_at) %>
                希望年収:<%= chat.interview.desired_income %>
                </span>
                </div>
                <div>
                  <CardListComponents.elapsed_time inserted_at={chat.updated_at} />
                </div>
              </div>
            </.link>
          <% end %>
        <% end %>
      </div>
      <!-- message -->
      <div class="w-full px-5 flex flex-col justify-between overflow-y-auto">
        <div
          class="flex flex-col mt-5"
          :if={@chat}
        >
          <p class="lg:ml-12 text-xl mb-2">
          ※メールアドレスや電話番号等の個人情報は送らないでください
          </p>
          <p class="lg:ml-12 text-xl mb-8">
          ※面談日時およびその重複は管理対象外ですので、別途管理を行ってください
          </p>
          <%= if Enum.count(@messages) == 0 do %>
          <div
            class="lg:ml-12 text-xl font-bold"
            :if={@current_user.id == @chat.owner_user_id && Accounts.hr_enabled?(@current_user.id)}
          >
            本チャットで面談候補者と面談の調整を行い、「面談確定の確認」ボタンを押してください
          </div>
          <% else %>
            <%= for message <- @messages do %>
              <%= if @current_user.id == message.sender_user_id do %>
              <div class="flex justify-end mb-4">
                <div class="text-xl mr-2 py-3 px-4 bg-blue-400 rounded-bl-3xl rounded-tl-3xl rounded-tr-xl text-white">
                  <%= nl_to_br(message.text) %>
                </div>
                <div>
                  <img
                    src={@sender_icon_path}
                    class="object-cover h-10 w-10 rounded-full mt-4"
                    alt=""
                  />
                  <span><%= @current_user.name %></span>
                </div>
              </div>

              <% else %>
              <div class="flex justify-start mb-4">
                <%= if @chat.owner_user_id == @current_user.id do %>
                  <%= if Interview.anon?(@chat.interview) do %>
                    <img
                      src={UserProfiles.icon_url(nil)}
                      class="object-cover h-10 w-10 rounded-full mt-4"
                      alt=""
                    />
                  <% else %>
                    <div class="flex flex-col justify-end">
                      <img
                        src={UserProfiles.icon_url(@chat.interview.candidates_user_icon)}
                        class="object-cover h-10 w-10 rounded-full mt-4"
                        alt=""
                      />
                      <p class="w-24 break-words"><%= @chat.interview.candidates_user_name %></p>
                    </div>
                  <% end %>

                <% else %>
                  <div class="flex flex-col justify-end">
                    <img
                      src={UserProfiles.icon_url(@chat.interview.recruiter_user_icon)}
                      class="object-cover h-10 w-10 rounded-full mt-4"
                      alt=""
                    />
                    <p class="w-24 break-words"><%= @chat.interview.recruiter_user_name %></p>
                  </div>
                <% end %>

                <div class="text-xl ml-2 py-3 px-4 bg-gray-400 rounded-br-3xl rounded-tr-3xl rounded-tl-xl text-white">
                <%= nl_to_br(message.text) %>
                </div>
              </div>
              <% end %>
            <% end %>
          <% end %>
        </div>
        <div
          class="py-5 sticky bottom-0 bg-white mb-12 lg:mb-0"
          :if={@chat}
        >
          <form phx-submit="send">
            <div class="flex pb-2">
              <div class="w-[50px] flex justify-center flex-col items-center">
                <img
                  class="inline-block h-10 w-10 rounded-full"
                  src={@sender_icon_path}
                />
              </div>
              <div class="w-full">
                  <textarea
                    class="w-full min-h-1 outline-none p-2"
                    placeholder="メッセージを入力"
                    name="message"
                    value={@message}
                  />
              </div>
            </div>

            <!-- モーダル内フッター -->
            <hr class="pb-1 border-brightGray-100">
            <div class="flex justify-end gap-x-4 pt-2 pb-2 relative w-full">
              <button class="mr-auto">
                <span class="material-icons-outlined !text-4xl opacity-50">
                  add_photo_alternate
                </span>
                <span class="material-symbols-outlined !text-4xl opacity-50">
                  add_box
                </span>
              </button>
              <.link navigate={~p"/recruits/chats"}>
                <button
                  type="button"
                  class="text-sm font-bold ml-auto px-2 py-[10px] rounded border bg-white w-24 lg:hidden"
                >
                  一覧に戻る
                </button>
              </.link>
              <div class="flex">
                <.link
                  phx-click="close_chat"
                  data-confirm="このチャットを閉じますか？"
                >
                  <button
                    type="button"
                    class="text-sm font-bold mr-2 px-2 py-3 rounded border bg-white w-36 lg:w-56"
                  >
                    チャットを閉じる
                  </button>
                </.link>
                <div
                  :if={@chat.owner_user_id == @current_user.id and @chat.interview.status != :cancel_interview and Accounts.hr_enabled?(@current_user.id)}
                >
                  <%= if @chat.interview.status == :consume_interview do %>
                    <button
                      class="text-sm font-bold ml-auto px-2 py-3 rounded border bg-base text-white w-56"
                      type="button"
                      phx-click={JS.push("open_confirm_interview") |> JS.show(to: "interview-confirm-modal")}
                    >
                      面談確定の確認
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
                <button
                  type="submit"
                  class="text-sm font-bold ml-2 px-2 py-3 rounded border bg-base text-white w-36 lg:w-56"
                >
                  メッセージを送る
                </button>
              </div>
            </div>
            <!-- end message -->
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
    |> assign(:sender_icon_path, UserProfiles.icon_url(user.user_profile.icon_file_path))
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
        %{assigns: %{messages: messages, current_user: user}} = socket
      ) do
    socket
    |> assign(:chats, Chats.list_chats(user.id, :recruit))
    |> assign(:messages, messages ++ [message])
    |> then(&{:noreply, &1})
  end

  defp nl_to_br(str), do: str |> String.replace(~r/\n/, "<br />") |> Phoenix.HTML.raw()

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

defmodule BrightWeb.ChatLive.Index do
  alias Bright.Chats
  use BrightWeb, :live_view

  alias Bright.UserProfiles
  alias Bright.CareerFields
  alias Bright.Recruits.Interview
  alias BrightWeb.CardLive.CardListComponents

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex flex-row justify-between bg-white ml-1 h-[calc(100vh-56px)]">
      <div class="flex flex-col min-w-[420px] border-r-2 overflow-y-auto">
        <%= for chat <- @chats do %>
          <.link
            class={"flex flex-row py-4 px-4 justify-center items-center border-b-2 cursor-pointer #{if chat.id == @chat.id, do: "border-l-4 border-l-blue-400"}"}
            patch={~p"/recruits/chats/#{chat.id}"}
          >
            <div class="w-16">
              <span class="material-icons text-lg text-white bg-brightGreen-300 rounded-full flex w-8 h-8 mr-2.5 items-center justify-center">
                person
              </span>
            </div>
            <div class="w-full flex">
              <div class="flex-1 mr-2 truncate text-xl">
                <%= Interview.career_fields(chat.interview, @career_fields) %>
              </div>
              <CardListComponents.elapsed_time inserted_at={chat.updated_at} />
            </div>
          </.link>
        <% end %>
      </div>
      <!-- message -->
      <div
        class="w-full px-5 flex flex-col justify-between overflow-y-auto"
        :if={@chat}
      >
        <div class="flex flex-col mt-5">
          <p class="ml-12 text-xl mb-2">
          ※メールアドレスや電話番号等の個人情報は送らないでください
          </p>
          <p class="ml-12 text-xl mb-8">
          ※面談日時の重複は管理対象外ですので、別途管理を行ってください
          </p>
          <%= if Enum.count(@messages) == 0 do %>
          <div class="ml-12 text-xl font-bold">
            下記にメッセージを入力し、「メッセージを送る」ボタンを押すと採用候補者にメッセージが届きます
          </div>
          <% else %>
            <%= for message <- @messages do %>
              <%= if @current_user.id == message.sender_user_id do %>
              <div class="flex justify-end mb-4">
                <div class="text-xl mr-2 py-3 px-4 bg-blue-400 rounded-bl-3xl rounded-tl-3xl rounded-tr-xl text-white">
                  <%= nl_to_br(message.text) %>
                </div>
                <img
                  src={@sender_icon_path}
                  class="object-cover h-10 w-10 rounded-full mt-4"
                  alt=""
                />
              </div>
              <% else %>
              <div class="flex justify-start mb-4">
                <img
                    src={@member_icon_path}
                    class="object-cover h-10 w-10 rounded-full mt-4"
                    alt=""
                  />
                  <div class="text-xl ml-2 py-3 px-4 bg-gray-400 rounded-br-3xl rounded-tr-3xl rounded-tl-xl text-white">
                  <%= nl_to_br(message.text) %>
                  </div>
                </div>
              <% end %>
            <% end %>
          <% end %>
        </div>
        <div
          class="py-5 sticky bottom-0 bg-white"
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

              <button
                type="submit"
                class="text-sm font-bold ml-auto px-2 py-2 rounded border bg-base text-white w-56"
              >
                メッセージを送る
              </button>
            </div>
            <div
              :if={@chat.owner_user_id == @current_user.id}
              class="flex justify-end gap-x-4 pt-2 pb-2 relative w-full"
            >
              <button class="text-sm font-bold ml-auto px-2 py-2 rounded border bg-base text-white w-56">
                採用確定でチャット終了
              </button>

              <button
                id="interviewDropdownButton"
                class="text-sm font-bold px-2 py-2 rounded border bg-white  w-56"
                type="button"
              >
                採用却下でチャット終了
              </button>
              <!-- 面談を辞退する Donwdrop -->
            </div>
            <!-- end message -->
          </form>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, %{assigns: %{current_user: user}} = socket) do
    socket
    |> assign(:sender_icon_path, UserProfiles.icon_url(user.user_profile.icon_file_path))
    |> assign(:member_icon_path, UserProfiles.icon_url(nil))
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
    |> assign(:page_title, "採用チャット")
    |> assign(:career_fields, CareerFields.list_career_fields())
    |> assign(:chats, Chats.list_chats(user.id, :recruit))
    |> assign(:chat, chat)
    |> assign(:messages, chat.messages)
    |> assign(:message, nil)
  end

  defp apply_action(socket, :recruit, _params) do
    user = socket.assigns.current_user

    socket
    |> assign(:page_title, "採用チャット")
    |> assign(:career_fields, CareerFields.list_career_fields())
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

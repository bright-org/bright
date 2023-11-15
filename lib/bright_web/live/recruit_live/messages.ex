defmodule BrightWeb.RecruitLive.Messages do
  use BrightWeb, :live_view

  alias Bright.UserProfiles
  alias Bright.CareerFields
  alias Bright.Recruits
  alias Bright.Recruits.Interview
  alias BrightWeb.CardLive.CardListComponents

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex flex-row justify-between bg-white ml-1 h-[calc(100vh-56px)]">
      <div class="flex flex-col min-w-[420px] border-r-2 overflow-y-auto">
        <%= for interview <- @interviews do %>
          <div
            class="flex flex-row py-4 px-4 justify-center items-center border-b-2 cursor-pointer"
            phx-click={JS.push("select_interview", value: %{id: interview.id})}
          >
            <div class="w-16">
              <span class="material-icons text-lg text-white bg-brightGreen-300 rounded-full flex w-8 h-8 mr-2.5 items-center justify-center">
                person
              </span>
            </div>
            <div class="w-full flex">
              <div class="flex-1 mr-2 truncate text-xl">
                <%= Interview.career_fields(interview, @career_fields) %>
              </div>
              <CardListComponents.elapsed_time inserted_at={interview.updated_at} />
            </div>
          </div>
        <% end %>
      </div>
      <!-- message -->
      <div
        class="w-full px-5 flex flex-col justify-between"
        :if={@selected_interview}
      >
        <%= if is_nil(@room) do %>
          <div class="flex justify-center items-center h-full">
            <p
              class="text-4xl cursor-pointer"
              phx-click="create_room"
            >
              チャットを開始する
            </p>
          </div>
        <% else %>
        <div class="flex flex-col mt-5">
          <div class="ml-12 text-xl mb-8">
          ※面談日時の重複は管理対象外ですので、別途管理を行ってください
          </div>
          <%= if Enum.count(@messages) == 0 do %>
          <div class="ml-12 text-xl font-bold">
            下記にメッセージを入力し、「メッセージを送る」ボタンを押すと採用候補者にメッセージが届きます
          </div>
          <% else %>
            <%= for message <- @messages do %>
            <div class="flex justify-start mb-4">
              <img
                src={@icon_file_path}
                class="object-cover h-10 w-10 rounded-full mt-4"
                alt=""
              />
              <div class="text-xl ml-2 py-3 px-4 bg-gray-400 rounded-br-3xl rounded-tr-3xl rounded-tl-xl text-white">
                <%= message %>
              </div>
            </div>
            <% end %>
          <% end %>
        </div>
        <% end %>
        <div
          class="py-5 sticky bottom-0"
          :if={@room}
        >
          <form  phx-submit="send">
            <div class="flex pb-2">
              <div class="w-[50px] flex justify-center flex-col items-center">
                <img
                  class="inline-block h-10 w-10 rounded-full"
                  src={@icon_file_path}
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
                <span class="material-icons-outlined !text-4xl">
                  add_photo_alternate
                </span>
                <span class="material-symbols-outlined !text-4xl">
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
            <div class="flex justify-end gap-x-4 pt-2 pb-2 relative w-full">
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
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    socket
    |> assign(:page_title, "採用チャット")
    |> assign(:icon_file_path, UserProfiles.icon_url(user.user_profile.icon_file_path))
    |> assign(:career_fields, CareerFields.list_career_fields())
    |> assign(:interviews, Recruits.list_interview(user.id, :consume_interview))
    |> assign(:selected_interview, nil)
    |> assign(:room, nil)
    |> assign(:messages, [])
    |> assign(:message, nil)
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_event("select_interview", %{"id" => interview_id}, socket) do
    {:noreply, assign(socket, :selected_interview, Recruits.get_interview!(interview_id))}
  end

  def handle_event("create_room", _params, socket) do
    # create chat room
    {:noreply, assign(socket, :room, %{})}
  end

  def handle_event("send", %{"message" => text}, socket) do
    {:noreply, assign(socket, :messages, socket.assigns.messages ++ [text])}
  end
end

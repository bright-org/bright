defmodule BrightWeb.ChatLive.ChatComponents do
  use BrightWeb, :component

  alias Bright.Recruits.Interview
  alias Bright.UserProfiles
  import BrightWeb.CardLive.CardListComponents, only: [elapsed_time: 1]

  attr :chat, :any, required: true
  attr :selected_chat, :any, required: true
  attr :user_id, :string, required: true

  def chat_list(assigns) do
    ~H"""
    <.link
      class={"flex py-4 px-4 justify-center items-center border-b-2 cursor-pointer #{if @selected_chat != nil && @selected_chat.id == @chat.id, do: "border-l-4 border-l-blue-400"}"}
      patch={~p"/recruits/chats/#{@chat.id}"}
    >
      <div class="mr-2">
        <.switch_user_icon chat={@chat} show_name={false} user_id={@user_id}/>
      </div>
      <div class="w-full flex justify-between p-1">
        <div class="mr-2 lg:truncate lg:text-xl">
          <span>
            <%= if @chat.interview.skill_panel_name == nil ,
              do: "スキルパネルデータなし",
              else: @chat.interview.skill_panel_name
            %>
          </span>
          <br />
          <span class="text-brightGray-300">
            <%= NaiveDateTime.to_date(@chat.interview.inserted_at) %>
            希望年収:<%= @chat.interview.desired_income %>
          </span>
        </div>
        <div>
          <.elapsed_time inserted_at={@chat.updated_at} />
        </div>
      </div>
    </.link>
    """
  end

  attr :current_user, :any, required: true
  attr :chat, :any, required: true
  attr :message, :any, required: true
  attr :sender_icon_path, :string, required: true

  def message(assigns) do
    ~H"""
    <%= if @current_user.id == @message.sender_user_id do %>
      <div class="flex justify-end">
        <div class="flex flex-col mb-4">
          <div class="flex">
            <div class="break-words max-w-[80vw] text-xl mr-2 py-3 px-4 bg-blue-400 rounded-bl-3xl rounded-tl-3xl rounded-tr-xl text-white">
              <%= nl_to_br(@message.text) %>
            </div>
            <div class="mt-4">
              <.user_icon path={@sender_icon_path} />
              <span><%= @current_user.name %></span>
            </div>
          </div>
          <p class="mt-1 flex justify-end"><.elapsed_time extend_style={"w-auto"} inserted_at={@message.inserted_at} /></p>
        </div>
      </div>
    <% else %>
      <div class="flex justify-start mb-4">
        <div class="mt-4">
          <.switch_user_icon
            chat={@chat}
            user_id={@current_user.id}
            anon={@chat.interview.recruiter_user_id == @current_user.id}
          />
        </div>

        <div class="break-words max-w-[80vw] text-xl ml-2 py-3 px-4 bg-gray-400 rounded-br-3xl rounded-tr-3xl rounded-tl-xl text-white">
          <%= nl_to_br(@message.text) %>
        </div>
      </div>
      <p class="-ml-4"><.elapsed_time inserted_at={@message.inserted_at} /></p>
    <% end %>
    """
  end

  attr :chat, :any, required: true
  attr :show_name, :boolean, default: true
  attr :user_id, :string, required: true
  attr :anon, :boolean, default: true

  def switch_user_icon(assigns) do
    assigns = set_user(assigns)

    ~H"""
      <%= if @anon and Interview.anon?(@chat.interview) do %>
        <.user_icon path={nil} />
      <% else %>
        <div class="flex flex-col justify-end">
          <.user_icon path={@user.icon}/>
          <p :if={@show_name} class="lg:w-24 break-words"><%= @user.name %></p>
        </div>
      <% end %>
    """
  end

  def user_icon(assigns) do
    ~H"""
      <img
      src={UserProfiles.icon_url(@path)}
      class="object-cover h-10 w-10 rounded-full"
      alt=""
    />
    """
  end

  defp set_user(assigns) do
    user =
      if assigns.chat.owner_user_id == assigns.user_id do
        %{
          name: assigns.chat.interview.candidates_user_name,
          icon: assigns.chat.interview.candidates_user_icon
        }
      else
        %{
          name: assigns.chat.interview.recruiter_user_name,
          icon: assigns.chat.interview.recruiter_user_icon
        }
      end

    Map.put(assigns, :user, user)
  end

  defp nl_to_br(str), do: str |> String.replace(~r/\n/, "<br />") |> Phoenix.HTML.raw()
end

defmodule BrightWeb.ChatLive.ChatComponents do
  use BrightWeb, :component

  alias Bright.Recruits.Interview
  alias Bright.UserProfiles
  alias Bright.Utils.GoogleCloud.Storage
  import BrightWeb.BrightCoreComponents, only: [elapsed_time: 1]

  attr :chat, :any, required: true
  attr :selected_chat, :any, required: true
  attr :user_id, :string, required: true
  attr :member_ids, :any, default: []
  attr :select_filter_type, :atom

  def chat_list(assigns) do
    ~H"""
    <.link
      class={[
        "flex py-4 px-4 justify-center items-center border-b-2 cursor-pointer",
        @selected_chat != nil && @selected_chat.id == @chat.id && "border-l-4 border-l-blue-400",
        !@chat.interview.is_read? && "bg-attention-50"
      ]}
      patch={~p"/recruits/chats/#{@chat.id}?select_filter_type=#{@select_filter_type}"}
    >
      <div class="mr-2">
        <.switch_user_icon
          chat={@chat}
          user_id={@user_id}
          anon={@chat.interview.recruiter_user_id == @user_id}
          member_ids={@member_ids}
        />
      </div>
      <div class="w-full flex justify-between p-1 relative">
        <span
          :if={!@chat.interview.is_read?}
          class="absolute bottom-0 right-0 h-3 w-3 bg-attention-300 rounded-full"
        />
        <%= if @chat.interview.status == :one_on_one do %>
          1on1
        <% else %>
          <div class="mr-2 lg:truncate max-w-36">
            <span>
              <%= if @chat.interview.skill_panel_name == nil,
                do: "スキルパネルデータなし",
                else: @chat.interview.skill_panel_name %>
            </span>
            <br />
            <span class="text-brightGray-300">
              <%= NaiveDateTime.to_date(@chat.interview.inserted_at) %>
            </span>
            <br />
            <span class="text-brightGray-300">
              希望年収:<%= @chat.interview.desired_income %>
            </span>
            <br />
            <span class="text-brightGray-300">
              <%= BrightWeb.ChatLive.Index.get_status(@chat.interview.status) %>
            </span>
          </div>
        <% end %>
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
    <%= if is_nil(@message.deleted_at) do %>
      <%= if @current_user.id == @message.sender_user_id do %>
        <div class="flex justify-end">
          <div class="flex flex-col mb-4">
            <div class="flex justify-end">
              <div class="break-words max-w-[80vw] text-xl mr-2 py-3 px-4 rounded-bl-3xl rounded-tl-3xl rounded-tr-xl text-white bg-blue-400">
                <%= nl_to_br(@message.text) %>
              </div>
              <div class="mt-4">
                <.user_icon path={@sender_icon_path} />
                <span><%= @current_user.name %></span>
              </div>
            </div>
            <p class="mt-1 flex justify-end">
              <.elapsed_time extend_style="w-auto" inserted_at={@message.inserted_at} />
            </p>
            <p class="flex justify-end">(<%= datetime(@message.inserted_at, "Asia/Tokyo") %>)</p>
            <div class="flex justify-end cursor-pointer" phx-click="delete_message" phx-value-message_id={@message.id} data-confirm="メッセージを削除しますか？">
              <span class="text-brightGray-500 hover:filter hover:brightness-[80%] hover:underline">削除&nbsp;</span><.icon name="hero-archive-box-x-mark-solid" class="w-6 h-6" />
            </div>
            <div class="flex justify-end gap-x-4">
              <%= for file <- Enum.filter(@message.files, & &1.file_type == :images) do %>
                <div
                  class="cursor-pointer hover:opacity-70"
                  phx-click="preview"
                  phx-value-preview={file.file_path}
                >
                  <img class="w-40 h-40" src={Storage.public_url(file.file_path)} />
                  <%= file.file_name %>
                </div>
              <% end %>
            </div>
            <div class="flex justify-end mt-4 gap-x-4">
              <%= for file <- Enum.filter(@message.files, & &1.file_type == :files) do %>
                <a
                  class="cursor-pointer hover:opacity-70 underline"
                  href={Storage.public_url(file.file_path)}
                  target="_blank"
                  rel="noopener"
                >
                  <.icon name="hero-document" class="w-24 h-24" /><br />
                  <%= file.file_name %>
                </a>
              <% end %>
            </div>
          </div>
        </div>
      <% else %>
        <div class="flex justify-start mb-4">
          <div class="mt-4">
            <.switch_user_icon
              chat={@chat}
              user_id={@current_user.id}
              anon={@chat.interview.recruiter_user_id == @current_user.id}
              has_link={true}
            />
          </div>

          <div class="break-words max-w-[80vw] text-xl ml-2 py-3 px-4 bg-gray-400 rounded-br-3xl rounded-tr-3xl rounded-tl-xl text-white">
            <%= nl_to_br(@message.text) %>
          </div>
        </div>
        <p class="-ml-4"><.elapsed_time inserted_at={@message.inserted_at} /></p>
        <p class="">(<%= datetime(@message.inserted_at, "Asia/Tokyo") %>)</p>
        <div class="flex justify-start">
          <%= for file <- Enum.filter(@message.files, & &1.file_type == :images) do %>
            <div
              class="cursor-pointer hover:opacity-70"
              phx-click="preview"
              phx-value-preview={file.file_path}
            >
              <img class="w-40 h-40" src={Storage.public_url(file.file_path)} />
              <%= file.file_name %>
            </div>
          <% end %>
        </div>
        <div class="w-full flex flex-col justify-end mt-4">
          <%= for file <- Enum.filter(@message.files, & &1.file_type == :files) do %>
            <a
              class="cursor-pointer hover:opacity-70 underline text-xl"
              href={Storage.public_url(file.file_path)}
              target="_blank"
              rel="noopener"
            >
              <.icon name="hero-document" class="w-24 h-24" /><br />
              <%= file.file_name %>
            </a>
          <% end %>
        </div>
      <% end %>
    <% end %>
    """
  end

  attr :chat, :any, required: true
  attr :show_name, :boolean, default: true
  attr :user_id, :string, required: true
  attr :anon, :boolean, default: true
  attr :member_ids, :any, default: []
  attr :has_link, :boolean, default: false

  def switch_user_icon(assigns) do
    assigns =
      set_user(assigns)
      |> set_url()

    ~H"""
    <div class="flex flex-col justify-end w-20 pl-2">
      <%= if anon?(@anon, @chat, @user) do %>
        <.user_icon path={nil} has_link={@has_link} url={@url} />
      <% else %>
        <.user_icon path={@user.icon} has_link={@has_link} url={@url}/>
        <p :if={@show_name} class="lg:w-20 break-words"><%= @user.name %></p>
      <% end %>
    </div>
    """
  end

  attr :path, :any
  attr :has_link, :boolean, default: false
  attr :url, :string, default: nil

  def user_icon(%{has_link: true} = assigns) do
    ~H"""
    <.link patch={@url} >
      <.user_icon path={@path} />
    </.link>
    """
  end

  def user_icon(assigns) do
    ~H"""
    <img src={UserProfiles.icon_url(@path)} class="object-cover h-10 w-10 rounded-full" alt="" />
    """
  end

  defp set_user(assigns) do
    user =
      if assigns.chat.owner_user_id == assigns.user_id do
        %{
          name: assigns.chat.interview.candidates_user_name,
          icon: assigns.chat.interview.candidates_user_icon,
          is_member: Enum.member?(assigns.member_ids, assigns.chat.interview.candidates_user_id)
        }
      else
        %{
          name: assigns.chat.interview.recruiter_user_name,
          icon: assigns.chat.interview.recruiter_user_icon,
          is_member: Enum.member?(assigns.member_ids, assigns.chat.interview.recruiter_user_id)
        }
      end

    Map.put(assigns, :user, user)
  end

  defp set_url(%{user: user, chat: chat, anon: anon} = assigns) do
    skill_panel =
      chat.interview.skill_params
      |> Jason.decode!()
      |> List.first()
      |> Map.get("skill_panel")

    url =
      if anon?(anon, chat, user) do
        user_by_name = Bright.Accounts.get_user_by_name(user.name)
        encrypted_name = BrightWeb.DisplayUserHelper.encrypt_user_name(user_by_name)
        "/graphs/#{skill_panel}/anon/#{encrypted_name}"
      else
        "/graphs/#{skill_panel}/#{user.name}"
      end

    assigns
    |> assign(url: url)
  end

  defp nl_to_br(str), do: str |> String.replace(~r/\n/, "<br />") |> Phoenix.HTML.raw()

  defp datetime(naive_datetime, "Asia/Tokyo") do
    naive_datetime
    |> NaiveDateTime.add(9, :hour)
    |> NaiveDateTime.to_string()
    |> String.slice(0, 16)
  end

  defp anon?(anon, chat, user), do: anon and Interview.anon?(chat.interview) and !user.is_member
end

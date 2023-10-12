defmodule BrightWeb.CardLive.CardListComponents do
  @moduledoc """
  Card List Components
  """
  use BrightWeb, :component

  @hour 60
  @day @hour * 24
  @highlight_minutes @hour * 8

  @doc """
  Renders a Card Row

  ## Examples
      <.card_row type="contact" notification={notification} />
  """
  attr :notification, :map, required: true

  attr :type, :string,
    values: [
      "operation",
      "skill_up",
      "1on1_invitation",
      "promotion",
      "your_team",
      "intriguing",
      "official_team"
    ]

  def card_row(%{type: "operation"} = assigns) do
    ~H"""
    <li class="flex flex-wrap">
      <div class="text-left flex flex-wrap items-center text-base px-1 py-1 flex-1 mr-2 w-full lg:w-auto lg:flex-nowrap">
        <span class="material-icons !text-lg text-white bg-brightGreen-300 rounded-full !flex w-6 h-6 mr-2.5 !items-center !justify-center">
          person
        </span>
        <span class="order-3 lg:order-2"><%= @notification.message %></span>
        <.elapsed_time inserted_at={@notification.inserted_at} />
      </div>
      <div class="flex gap-x-2 w-full justify-end lg:justify-start lg:w-auto">
        <.link patch={~p"/mypage/notification_detail/operation/#{@notification.id}"} >
          <button class="text-bold inline-block bg-brightGray-900 !text-white min-w-[76px] rounded py-1 px-2 text-sm" >
            内容を見る
          </button>
        </.link>
      </div>
    </li>
    """
  end

  def card_row(%{type: "skill_up"} = assigns) do
    # TODO　仮実装 「祝福する」ボタンの活性、非活性
    assigns =
      assigns
      |> assign(:disabled, true)

    ~H"""
    <li class="flex">
      <div class="text-left flex items-center text-base px-1 py-1 hover:bg-brightGray-50 flex-1 mr-2">
        <span class="material-icons-outlined !text-sm !text-white bg-brightGreen-300 rounded-full !flex w-6 h-6 mr-2.5 !items-center !justify-center">
          <%= @notification.icon_type %>
        </span>
        <%= @notification.message %>
        <.elapsed_time inserted_at={@notification.inserted_at} />
      </div>
      <div class="flex gap-x-2">
        <button disabled={@disabled} class={["text-bold inline-block", if(@disabled, do: "bg-brightGray-300 text-sm cursor-not-allowed", else: "bg-brightGray-900" ), "!text-white min-w-[76px] rounded py-1 px-1 text-sm"]} >
          祝福する
        </button>
      </div>
    </li>
    """
  end

  def card_row(%{type: "1on1_invitation"} = assigns) do
    # TODO　仮実装 「受ける」「断る」ボタンの活性、非活性
    assigns =
      assigns
      |> assign(:disabled, true)
      |> assign(:visible, true)

    ~H"""
    <li class="flex">
      <div class="text-left flex items-center text-base px-1 py-1 hover:bg-brightGray-50 flex-1 mr-2">
        <span class="material-icons !text-sm !text-white bg-brightGreen-300 rounded-full !flex w-6 h-6 mr-2.5 !items-center !justify-center">
          <%= @notification.icon_type %>
        </span>
        <%= @notification.message %>
        <.elapsed_time inserted_at={@notification.inserted_at} />
      </div>
      <div :if={@visible} class="flex gap-x-2">
        <button disabled={@disabled} class={["text-bold inline-block", if(@disabled, do: "bg-brightGray-300 cursor-not-allowed",  else: "bg-brightGray-900"), "!text-white min-w-[76px] rounded py-1 px-1 text-sm"]}>
          受ける
        </button>
        <button disabled={@disabled} class={["!text-bold inline-block border", if(@disabled, do: "border-brightGray-300 text-brightGray-300 cursor-not-allowed", else: "border-brightGray-900"),  "min-w-[76px] rounded py-1 px-1 text-sm text-base"]}>
          断る
        </button>
      </div>
    </li>
    """
  end

  def card_row(%{type: "promotion"} = assigns) do
    ~H"""
    <li class="flex">
      <div class="text-left flex items-center text-base px-1 py-1 hover:bg-brightGray-50 flex-1 mr-2">
        <span class="material-icons !text-sm !text-white bg-brightGreen-300 rounded-full !flex w-6 h-6 mr-2.5 !items-center !justify-center">
          <%= @notification.icon_type %>
        </span>
        <%= @notification.message %>
        <.elapsed_time inserted_at={@notification.inserted_at} />
      </div>
      <div class="flex gap-x-2">
        <button class="text-bold inline-block bg-brightGray-900 !text-white min-w-[76px] rounded py-1 px-1 text-sm">
          見に行く
        </button>
      </div>
    </li>
    """
  end

  def card_row(%{type: "your_team"} = assigns) do
    ~H"""
    <li class="py-1 text-left flex items-center text-base hover:bg-brightGray-50 px-1">
      <span class="material-icons-outlined !text-sm !text-white bg-brightGreen-300 rounded-full !flex w-6 h-6 mr-2.5 !items-center !justify-center">
        <%= @notification.icon_type %>
      </span>
      <%= @notification.message %>
      <.elapsed_time inserted_at={@notification.inserted_at} />
    </li>
    """
  end

  def card_row(%{type: "intriguing"} = assigns) do
    ~H"""
    <li class="flex">
      <div class="text-left flex items-center text-base px-1 py-1 hover:bg-brightGray-50 flex-1 mr-2">
        <span class="material-icons !text-sm !text-white bg-brightGreen-300 rounded-full !flex w-6 h-6 mr-2.5 !items-center !justify-center">
          <%= @notification.icon_type %>
        </span>
        <%= @notification.message %>
        <.elapsed_time inserted_at={@notification.inserted_at} />
      </div>
      <div class="flex gap-x-2">
        <button class="text-bold inline-block bg-brightGray-900 !text-white min-w-[76px] rounded py-1 px-3 text-sm">
          相手を見る
        </button>
      </div>
    </li>
    """
  end

  def card_row(%{type: "community"} = assigns) do
    # TODO　仮実装 「参加する」「脱退する」切り替え
    assigns =
      assigns
      |> assign(:participated, true)

    ~H"""
    <li class="flex">
      <div class="text-left flex items-center text-base px-1 py-1 hover:bg-brightGray-50 flex-1 mr-2">
        <img src="/images/common/icons/other_team.svg" class="mr-2"/>
        <%= @notification.message %>
        <.elapsed_time inserted_at={@notification.inserted_at} />
      </div>
      <div class="flex gap-x-2">
        <button :if={!@participated} class="text-bold inline-block bg-brightGray-900 !text-white min-w-[76px] rounded py-1 px-1 text-sm">
          参加する
        </button>
        <button :if={@participated} class="!text-bold inline-block border border-brightGray-900 min-w-[76px] rounded py-1 px-1 text-base !text-sm">
          脱退する
        </button>
      </div>
    </li>
    """
  end

  attr :inserted_at, :any

  defp elapsed_time(assigns) do
    {:ok, inserted_at} = DateTime.from_naive(assigns.inserted_at, "Etc/UTC")

    minutes =
      DateTime.diff(DateTime.utc_now(), inserted_at, :minute)
      |> trunc()

    style =
      highlight(minutes < @highlight_minutes) <>
        " font-bold pl-0 inline-block w-full text-sm order-1 lg:pl-4 lg:order-3 lg:w-auto"

    assigns =
      assigns
      |> assign(:style, style)
      |> assign(:time_text, time_text(minutes))

    ~H"""
    <span class={@style}><%= @time_text %></span>
    """
  end

  defp time_text(minutes) when minutes < @hour, do: "#{minutes}分前"
  defp time_text(minutes) when minutes < @day, do: "#{trunc(minutes / @hour)}時間前"
  defp time_text(minutes), do: "#{trunc(minutes / @day)}日前"

  defp highlight(true), do: "text-brightGreen-300"
  defp highlight(false), do: "text-brightGray-300"
end

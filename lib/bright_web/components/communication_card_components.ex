defmodule BrightWeb.CommunicationCardComponents do
  @moduledoc """
  Communication Card Components
  """
  use Phoenix.Component
  import BrightWeb.TabComponents

  @doc """
  Renders a Communication Card

  ## Communications sample
    [
      %{icon_type: "pentagon", message: "中道洋介さんがスキルアップしました", time: 1, highlight: true},
      %{icon_type: "pentagon", message: "清水太郎さんがスキルアップしました", time: 10, highlight: false}
    ]

  ## Examples
      <.communication_card communications={@communications} />
  """

  # TODO communicationsのdefault現在サンプルデータとして使ってます、DBのロジック作成後削除
  attr :communications, :list,
    default: [
      %{icon_type: "pentagon", message: "中道洋介さんがスキルアップしました", time: 1, highlight: true},
      %{icon_type: "pentagon", message: "清水太郎さんがスキルアップしました", time: 10, highlight: false}
    ]

  def communication_card(assigns) do
    ~H"""
    <div>
      <h5>さまざまな人たちとの交流</h5>
      <.tab tabs={["スキルアップ", "1on1のお誘い", "所属チームから", "「気になる」された", "運勢公式チーム発足"]}>
        <ul class="flex gap-y-2.5 flex-col">
          <%= for communication <- @communications do %>
            <.communication_card_row communication={communication} />
          <% end %>
        </ul>
      </.tab>
    </div>
    """
  end

  attr :communication, :map, required: true

  def communication_card_row(assigns) do
    style = highlight(assigns.communication.highlight) <> " font-bold pl-4 inline-block"

    assigns =
      assigns
      |> assign(:style, style)

    ~H"""
    <li class="text-left flex items-center text-base hover:bg-brightGray-50 px-1">
      <span class="material-icons-outlined !text-sm !text-white bg-brightGreen-300 rounded-full !flex w-6 h-6 mr-2.5 !items-center !justify-center">
        <%= @communication.icon_type %>
      </span>
      <%= @communication.message %>
      <span class={@style}><%= "#{@communication.time}時間前" %></span>
    </li>
    """
  end

  # TODO 共通化対象
  defp highlight(true), do: "text-brightGreen-300"
  defp highlight(false), do: "text-brightGray-300"
end

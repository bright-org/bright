defmodule BrightWeb.ChartLive.SkillGemComponent do
  @moduledoc """
  Skill Gem Component
  """
  use BrightWeb, :live_component
  import BrightWeb.ChartComponents
  alias Bright.SkillScores
  alias Bright.HistoricalSkillScores
  alias BrightWeb.PathHelper
  alias BrightWeb.TimelineHelper

  # SkillGemComponentの引数
  # id: 一意になるid
  # display_user: 表示するユーザー
  # skill_panel: 表示するキルパネル
  # class: 表示するクラス(1〜3)
  # select_label 表示する時間　"now" or 例 "2023.10"
  # me: 自分自身の場合はtrue
  # anonymous: 匿名はfalse
  # size: base: 成長グラフ md:チーム分析 sm:マイページ
  # display_link:　falseでスキルジェムのリンクを非表示にする

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto w-full -mt-24 lg:mt-0 lg:w-[450px]">
      <%= if length(@skill_gem_labels) < 3 do %>
        <div class="bg-white w-[450px] h-[360px] flex items-center justify-center">
          <p class="text-start font-bold">データが破損しています</p>
        </div>
      <% else %>
        <.skill_gem
          data={@skill_gem_data}
          id={@id}
          labels={@skill_gem_labels}
          links={@skill_gem_links}
          display_link={@display_link}
          size={@size}
        />
      <% end %>
    </div>
    """
  end

  @impl true
  def update(
        %{
          display_user: display_user,
          skill_panel: skill_panel,
          class: class,
          me: me,
          anonymous: anonymous
        } = assigns,
        socket
      ) do
    socket =
      socket
      |> assign(assigns)

    select_label = assigns[:select_label] || "now"
    display_link = assigns[:display_link] || "true"
    size = assigns[:size] || "base"
    skill_gem = get_skill_gem(display_user.id, skill_panel.id, class, select_label)

    socket =
      socket
      |> assign(:skill_gem_data, get_skill_gem_data(skill_gem))
      |> assign(:skill_gem_labels, get_skill_gem_labels(skill_gem))
      |> assign(
        :skill_gem_links,
        get_skill_gem_links(skill_gem, skill_panel, class, display_user, me, anonymous)
      )
      |> assign(:display_link, display_link)
      |> assign(:size, size)

    {:ok, socket}
  end

  def get_skill_gem(user_id, skill_panel_id, class, select_label) when select_label == "now",
    do: SkillScores.get_skill_gem(user_id, skill_panel_id, class)

  def get_skill_gem(user_id, skill_panel_id, class, select_label) do
    locked_date = label_to_date(select_label)

    skill_gem =
      HistoricalSkillScores.get_historical_skill_gem(
        user_id,
        skill_panel_id,
        class,
        TimelineHelper.get_shift_date_from_date(locked_date, -1)
      )

    if skill_gem == [] do
      get_skill_gem(user_id, skill_panel_id, class, "now")
      |> Enum.map(fn x -> Map.put(x, :percentage, 0) end)
    else
      skill_gem
    end
  end

  defp label_to_date(date) do
    "#{date}.1"
    |> String.split(".")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
    |> Date.from_erl!()
  end

  defp get_skill_gem_data(skill_gem), do: [skill_gem |> Enum.map(fn x -> x.percentage end)]
  defp get_skill_gem_labels(skill_gem), do: skill_gem |> Enum.map(fn x -> x.name end)

  defp get_skill_gem_links(skill_gem, skill_panel, class, display_user, me, anonymous) do
    base_path =
      PathHelper.skill_panel_path("panels", skill_panel, display_user, me, anonymous) <>
        "?class=#{class}"

    skill_gem
    |> Enum.map(fn x -> "#{base_path}#unit-#{x.position}" end)
  end
end

defmodule BrightWeb.SkillCardComponents do
  @moduledoc """
  Skill Card Components
  """
  use Phoenix.Component
  import BrightWeb.TabComponents

  @doc """
  Renders a Skill Card

  ## Examples
      <.skill_card />
  """
  def skill_card(assigns) do
    ~H"""
    <div>
      <h5>保有スキル（ジェムをクリックすると成長グラフが見れます）</h5>
      <.tab tabs={["エンジニア", "インフラ", "デザイナー", "マーケッター"]}>
        <.skill_card_body />
      </.tab>
    </div>
    """
  end

  def skill_card_body(assigns) do
    ~H"""
    <div class="py-4 px-7 flex gap-y-3 flex-col">
      <%= for _i <- 1..3 do %>
        <.skill_card_genre />
      <% end %>
    </div>
    """
  end

  def skill_card_genre(assigns) do
    ~H"""
    <div class="bg-brightGray-10 rounded-md text-base flex p-5 content-between">
      <p class="font-bold w-36 text-left text-sm">
        Webアプリ開発
      </p>
      <table class="table-fixed skill-table">
        <thead>
          <tr>
            <th class="w-[110px]"></th>
            <th class="pl-8">クラス1</th>
            <th class="pl-8">クラス2</th>
            <th class="pl-8">クラス3</th>
          </tr>
        </thead>
        <tbody>
          <%= for _j <- 1..3 do %>
            <tr>
              <td>Elixir</td>
              <.skill_card_genre_cell />
              <.skill_card_genre_cell />
              <.skill_card_genre_cell />
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end

  # TODO
  # <img src="./images/common/icons/jemLow.svg" class="mr-1" />見習い
  # <img src="./images/common/icons/jemMiddle.svg" class="mr-1" />平均
  # <img src="./images/common/icons/jemHigh.svg" class="mr-1" />ベテラン

  def skill_card_genre_cell(assigns) do
    ~H"""
    <td>
    <p class="hover:bg-brightGray-50 hover:cursor-pointer inline-flex items-end p-1">
      <img src="./images/common/icons/jemHigh.svg" class="mr-1" />ベテラン
    </p>
    </td>
    """
  end
end

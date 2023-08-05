defmodule BrightWeb.TeamComponents do
  @moduledoc """
  Team Components
  """
  use Phoenix.Component
  import BrightWeb.ChartComponents

  @doc """
  アイコン付きのチームコンポーネント

  - team 表示対象のチーム
  - team_type チームの種類（アイコン表示出しわけに使用する)
  - low_on_click_target チームの表示をクリックした際に発火するon_card_row_clickイベントハンドラのターゲット。指定されない場合nilがデフォルト指定される為、大本のliveviewがターゲットとなる。

  ## Examples
      <.team_small
        team=%{Brignt.Team}
        team_type={:general_team}
        low_on_click_target=@myself
      />
  """
  attr :team, Bright.Teams.Team, required: true
  attr :team_type, :atom, default: :general_team
  attr :low_on_click_target, :any, required: false, default: nil

  def team_small(assigns) do
    ~H"""
    <li
      phx-click="on_card_row_click"
      phx-target={@low_on_click_target}
      phx-value-team_id={@team.id}
      class="text-left flex items-center text-base hover:bg-brightGray-50 p-1 rounded"
    >
      <img src={get_team_icon_path(@team_type)} class="mr-2"/>
      <%= @team.name %>
    </li>
    """
  end

  attr :team, Bright.Teams.Team, required: true
  attr :team_type, :atom, default: :general_team

  def team_skill_panels(assigns) do
    ~H"""
    <div class="flex items-center">
    <h3>
      <span
        class="material-icons !text-xl text-white bg-brightGreen-300 rounded-full !inline-flex w-8 h-8 mr-2.5 !items-center !justify-center">
        group
      </span>
      <%= assigns.team.name %>
    </h3>
    <label
      class="text-white bg-lapislazuli-300 ml-8 rounded-md font-bold px-3 inline-flex items-center h-7">
      プライマリ
    </label>
    </div>
    """
  end

  attr :id, :string
  attr :user, Bright.Accounts.User, required: true

  def user_skill_card(assigns) do
    ~H"""
      <div class="flex w-[474px] shadow flex-col bg-white">
        <ul
          class="flex text-md font-bold text-brightGray-500 bg-skillGem-50 content-between w-full"
        >
          <li class="bg-white text-base w-full">
            <a
              href="#"
              class="w-full py-3 text-center inline-block"
              aria-current="page"
            >
              クラス1
              <span class="text-xl ml-4">52</span>％</a>
          </li>
          <li class="w-full">
            <a href="#" class="w-full py-3 text-center inline-block"
              >クラス2 <span class="text-xl ml-4">52</span>％</a>
          </li>
          <li class="w-full">
            <a href="#" class="w-full py-3 text-center inline-block"
              >クラス3 <span class="text-xl ml-4">52</span>％</a>
          </li>
        </ul>
        <div class="flex justify-between px-6 pt-1 items-center">
          <div class="text-2xl font-bold">piacere</div>
          <div
            class="bg-test bg-contain h-20 w-20 mt-4"
            style="
              background-image: url('./images/sample/sample-image.png');
            "
          ></div>
        </div>
        <div class="w-[400px] flex justify-center mx-auto">
          <!-- <canvas id="radarChart" width="300" height="300"></canvas> -->
          <.skill_gem
        data={[[50, 60, 40, 30, 75, 60]]}
        id={@id}
        display_link="false"
        labels={["エンジニア", "マーケター", "デザイナー", "インフラ", "営業", "昼寝"]}
      />
        </div>
        <!--
        <div class="p-6 pt-0 flex justify-between">
          <button
            class="text-sm font-bold px-5 py-3 rounded text-white bg-base"
          >
            1on1に誘う
          </button>
          <button
            class="text-sm font-bold px-5 py-3 rounded border border-base"
          >
            この人と比較
          </button>
          <button
            class="text-sm font-bold px-5 py-3 rounded border border-base"
          >
            スキルアップ確認
          </button>
        </div>
        -->
      </div>
    """
  end

  @doc """
  チーム種別を示す文字列からアイコンのパスを取得する
  """
  def get_team_icon_path(team_type) do
    # TODO 全チーム種別のアイコンの追加、関数の実装場所の相談
    icons = [
      {:general_team, "/images/common/icons/team.svg"}
    ]

    icons[team_type]
  end
end

defmodule BrightWeb.TeamComponents do
  @moduledoc """
  Team Components
  """
  use Phoenix.Component

  @doc """
  アイコン付きのチームコンポーネント

  - team 表示対象のチーム
  - team_type チームの種類（アイコン表示出しわけに使用する)
  - low_on_click_target チームの表示をクリックした際に発火するon_card_row_clickイベントハンドラのターゲット。指定されない場合nilがデフォルト指定される為、大本のliveviewがターゲットとなる。

  ## Examples
      <.team_small
        id="123"
        team=%{Brignt.Team}
        team_type={:general_team}
        low_on_click_target=@myself
      />
  """

  attr :id, :string, required: true
  attr :team, Bright.Teams.Team, required: true
  attr :team_type, :atom, default: :general_team
  attr :low_on_click_target, :any, required: false, default: nil

  def team_small(assigns) do
    ~H"""
    <li
      id={@id}
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
  attr :current_users_team_member, Bright.Teams.TeamMemberUsers, required: true

  def team_header(assigns) do
    ~H"""
    <div class="flex gap-x-4">
      <h3>
        <span
          class="material-icons !text-xl text-white bg-brightGreen-300 rounded-full !inline-flex w-8 h-8 mr-2.5 !items-center !justify-center">
          group
        </span>
        <%= @team.name %>
      </h3>
      <button
        class={"bg-white border border-#{get_star_style(@current_users_team_member)} rounded px-1 h-8 flex items-center mt-auto mb-1"}
        phx-click="click_star_button"
      >
        <span
          class={"material-icons text-#{get_star_style(@current_users_team_member)}"}
        >
          star
        </span>
      </button>
    </div>
    """
  end

  defp get_team_icon_path(team_type) do
    # TODO 全チーム種別のアイコンの追加、関数の実装場所の相談
    icons = [
      {:general_team, "/images/common/icons/team.svg"}
    ]

    icons[team_type]
  end

  defp get_star_style(team_member_user) do
    if team_member_user.is_star do
      "brightGreen-300"
    else
      # TODO スターのOFFの時の色指定確認
      "brightGray-500"
    end
  end
end

defmodule BrightWeb.TeamComponents do
  @moduledoc """
  Team Components
  """
  use Phoenix.Component

  @doc """
  アイコン付きのチームコンポーネント

  ## Examples
      <.team_small
        team=%{Brignt.Team}
        icon_file_path="/images/common/icons/team.svg"
      />
  """
  attr :team, Bright.Teams.Team, required: true
  attr :team_type, :atom, default: :general_team

  def team_small(assigns) do
    ~H"""
    <li
    class="text-left flex items-center text-base hover:bg-brightGray-50 p-1 rounded">
      <img src={get_team_icon_path(@team_type)} class="mr-2"/>
      <%= assigns.team.name %>
    </li>
    """
  end

  @doc """
  チーム種別を示す文字列からアイコンのパスを取得する
  """
  def get_team_icon_path(team_type) do
    # TODO 全チーム種別のアイコンの追加、関数の実装場所の相談
    icons = [
      {:general_team, "./images/common/icons/team.svg"}
    ]

    icons[team_type]
  end
end

defmodule BrightWeb.TeamComponents do
  @moduledoc """
  Team Components
  """
  use Phoenix.Component

  alias Bright.Teams.TeamMemberUsers
  alias Bright.Teams
  alias Bright.Teams.Team

  @doc """
  アイコン付きのチームコンポーネント

  - team 表示対象のチーム
  - team_type チームの種類（アイコン表示出しわけに使用する)
  - row_on_click_target チームの表示をクリックした際に発火するon_card_row_clickイベントハンドラのターゲット。指定されない場合nilがデフォルト指定される為、大本のliveviewがターゲットとなる。
  - on_hover_style ホバー時のカーソル変更要スタイル 変更させたくない場合はブランクで上書き

  ## Examples
      <.team_small
        id="123"
        team_params=@team_params
        row_on_click_target=@myself
      />
  """

  attr :id, :string, required: true
  attr :team_params, :map, required: true
  attr :row_on_click, :string, required: false, default: "on_card_row_click"
  attr :row_on_click_target, :any, required: false, default: nil

  attr :on_hover_style, :string,
    required: false,
    default: " hover:bg-brightGray-50 cursor-pointer"

  def team_small(assigns) do
    ~H"""
    <li
      id={@id}
      phx-click={@row_on_click}
      phx-target={@row_on_click_target}
      phx-value-team_id={@team_params.team_id}
      phx-value-team_type={@team_params.team_type}
      class={"text-left flex items-center text-base p-1 rounded" <> @on_hover_style}
    >

    <span
    :if={@team_params.is_star == nil}
    >
    </span>
      <span
        :if={@team_params.is_star == true}
        class="material-icons text-brightGreen-300"
      >
        star
      </span>
      <span
        :if={@team_params.is_star == false}
        class="material-icons text-brightGray-100"
      >
        star
      </span>
      <img src={get_team_icon_path(@team_params.team_type)} class="ml-2 mr-2"/>
      <%= @team_params.name %>
      <span
        :if={@team_params.is_admin}
        class="text-white text-sm font-bold ml-4 px-2 py-1 inline-block bg-lapislazuli-300 rounded min-w-[60px]"
      >
        管理者
      </span>
    </li>
    """
  end

  attr :team_name, :string, required: true
  attr :team_type, :atom, default: :general_team
  attr :current_users_team_member, Bright.Teams.TeamMemberUsers, required: false, default: nil

  def team_header(assigns) do
    ~H"""
    <div class="flex gap-x-4">
      <h3>
        <img src={get_team_icon_path(@team_type)} class="ml-2 mr-2 !inline-flex w-8 h-8 !items-center !justify-center"/>
        <%= @team_name %>
      </h3>
      <button
        :if={show_star_button?(@current_users_team_member)}
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

  def convert_team_params_from_teams(teams) do
    teams
    |> Enum.map(fn team ->
      convert_team_params_from_team(team)
    end)
  end

  def convert_team_params_from_team(%Team{} = team) do
    %{
      team_id: team.id,
      name: team.name,
      is_star: nil,
      is_admin: nil,
      team_type: Teams.get_team_type_by_team(team)
    }
  end

  def convert_team_params_from_team_member_users(team_member_users) do
    team_member_users
    |> Enum.map(fn team_member_user ->
      %{
        team_id: team_member_user.team.id,
        name: team_member_user.team.name,
        is_star: team_member_user.is_star,
        is_admin: team_member_user.is_admin,
        team_type: Teams.get_team_type_by_team(team_member_user.team)
      }
    end)
  end

  defp get_team_icon_path(team_type) do
    # TODO 全チーム種別のアイコンの追加、関数の実装場所の相談
    icons = get_team_types()
    icons[team_type]
  end

  defp get_team_types() do
    [
      # 一般のチームと人材・支援チームのアイコンはおなじ
      {:general_team, "/images/common/icons/team.svg"},
      {:custom_group, "/images/common/icons/coustom_group.svg"},
      {:hr_support_team, "/images/common/icons/team_hr_support.svg"},
      {:teamup_team, "/images/common/icons/team_teamup.svg"}
    ]
  end

  defp show_star_button?(%TeamMemberUsers{}) do
    # チームメンバーの場合はスターのon/off可能
    true
  end

  defp show_star_button?(_), do: false

  defp get_star_style(team_member_user) do
    if team_member_user.is_star do
      "brightGreen-300"
    else
      # TODO スターのOFFの時の色指定確認
      "brightGray-500"
    end
  end
end

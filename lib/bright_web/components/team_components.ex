defmodule BrightWeb.TeamComponents do
  @moduledoc """
  Team Components
  """
  use Phoenix.Component

  import BrightWeb.CoreComponents, only: [icon: 1]

  alias Bright.Teams.TeamMemberUsers
  alias Bright.Teams
  alias Bright.Teams.Team
  alias Bright.Subscriptions

  # チームタイプ事の定義(UI向け) Teamsの方のリストと異なりカスタムグループもチーム扱い
  @team_types [
    {:general_team, "/images/common/icons/team.svg"},
    {:custom_group, "/images/common/icons/coustom_group.svg"},
    {:hr_support_team, "/images/common/icons/team_hr_support.svg"},
    {:teamup_team, "/images/common/icons/team_teamup.svg"}
  ]

  @team_type_select_list [
    %{
      display_name: "一般チーム",
      team_type: :general_team,
      visiblily_check_function: &Teams.always_true?/1
    },
    %{
      display_name: "チームアップチーム",
      team_type: :teamup_team,
      visiblily_check_function: &Subscriptions.service_team_up_enabled?/1
    },
    %{
      display_name: "採用・育成チーム",
      team_type: :hr_support_team,
      visiblily_check_function: &Subscriptions.service_hr_basic_enabled?/1
    }
  ]

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
      class="h-[35px] text-left flex items-center text-base hover:bg-brightGray-50 p-1 rounded cursor-pointer"
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
      <span class="max-w-[160px] lg:max-w-[280px] truncate"><%= @team_params.name %></span>
      <span
        :if={@team_params.is_admin}
        class="text-white text-sm font-bold ml-6 px-2 py-1 inline-block bg-lapislazuli-300 rounded min-w-[60px]"
      >
        管理者
      </span>
      <.link
        :if={@team_params.is_admin && Map.get(@team_params, :free_trial_together_link?)}
        navigate="/free_trial?plan=together"
        class="text-white text-sm font-bold ml-4 px-2 py-1 inline-flex items-center bg-base rounded min-w-[60px]"
      >
        上限を増やす
        <.icon name="hero-arrow-right" class="w-4 h-4" />
      </.link>
    </li>
    """
  end

  attr :id, :string, required: true
  attr :team_params, :map, required: true

  attr :on_hover_style, :string,
    required: false,
    default: " hover:bg-brightGray-50 cursor-pointer"

  def team_minimum(assigns) do
    ~H"""
    <li
      id={@id}
      class="h-[35px] text-left flex items-center text-base hover:bg-brightGray-50 p-1 rounded cursor-pointer"
    >
      <img src={get_team_icon_path(@team_params.team_type)} class="ml-2 mr-2"/>
      <span class="max-w-[160px] lg:max-w-[280px] truncate"><%= @team_params.name %></span>
    </li>
    """
  end

  attr :team_name, :string, required: true
  attr :team_type, :atom, default: :general_team
  attr :current_users_team_member, Bright.Teams.TeamMemberUsers, required: false, default: nil
  attr :team_size, :integer, default: 0
  attr :level_count, :list, default: []

  def team_header(assigns) do
    ~H"""
    <div class="flex flex-col">
      <div class="flex gap-x-4 h-8" >
        <h3 class="max-w-[1000px] truncate">
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
        <h3>
        <%= @team_size %>人
        </h3>

      </div>
      <div>
        <.team_header_sum
        level_count={@level_count}
        />
      </div>
    </div>
    """
  end

  def team_header_sum(assigns) do
    assigns = assigns |> assign(:css, "pt-0 text-xs leading-3")

    ~H"""
    <table>
      <tr>
       <td class={@css}></td>
       <td class={@css}>クラス1</td>
       <td class={@css}>クラス2</td>
       <td class={@css}>クラス3</td>
      </tr>
      <.team_header_sum_row name="見習い" row={Enum.at(@level_count,0)}/>
      <.team_header_sum_row name="平均" row={Enum.at(@level_count,1)}/>
      <.team_header_sum_row name="ベテラン" row={Enum.at(@level_count,2)}/>

    </table>
    """
  end

  @spec team_header_sum_row(map()) :: Phoenix.LiveView.Rendered.t()
  def team_header_sum_row(assigns) do
    assigns = assigns |> assign(:css, "pt-0 text-xs leading-3")

    ~H"""
    <tr>
      <td class={@css}><%= @name %></td>
      <td class={@css}><%= Enum.at(@row, 0) %></td>
      <td class={@css}><%= Enum.at(@row, 1) %></td>
      <td class={@css}><%= Enum.at(@row, 2) %></td>
    </tr>
    """
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

  def convert_team_params_from_teams(teams) do
    teams
    |> Enum.map(fn team ->
      convert_team_params_from_team(team)
    end)
  end

  attr :selected_team_type, :any, required: true
  attr :phx_target, :any, default: ""
  attr :is_clickable?, :boolean, default: false
  attr :user_id, :any, required: true

  def team_type_select_dropdown_menue(assigns) do
    assigns =
      assigns
      |> Map.put(:team_type_select_list, @team_type_select_list)

    ~H"""
    <div
      :if={!assigns.is_clickable? || length(filter_team_type_select_list_by_user_id(@user_id)) <= 1}
    >
      <div
        class={"text-left flex items-center text-base p-1 rounded border border-brightGray-100 bg-white w-full"}
        type="button"
      >
        <img src={get_team_icon_path(@selected_team_type)} class="ml-2 mr-2"/>
        <%= get_display_name(@selected_team_type) %>
      </div>
    </div>
    <div
      :if={assigns.is_clickable? && length(filter_team_type_select_list_by_user_id(@user_id)) >= 2}
      id={"{@id}"}
      phx-hook="Dropdown"
      data-dropdown-offset-skidding="0"
      data-dropdown-placement="bottom"
    >
      <bottun
          class={"text-left flex items-center text-base p-1 rounded border border-brightGray-100 bg-white w-full  hover:bg-brightGray-50 dropdownTrigger"}
          type="button"
        >
        <img src={get_team_icon_path(@selected_team_type)} class="ml-2 mr-2"/>
        <%= get_display_name(@selected_team_type) %>
      </bottun>
      <p
      >
        チームタイプを選択してください
      </p>
      <!-- menue list-->
      <div
          :if={@is_clickable?}
          class="dropdownTarget z-30 hidden bg-white rounded-sm shadow static w-full lg:w-[340px]"
        >
        <ul>
          <%= for team_type_item <- filter_team_type_select_list_by_user_id(@user_id) do %>
            <li
              class="text-left flex items-center text-base hover:bg-brightGray-50 p-1 bg-white w-full"
              phx-click="select_team_type"
              phx-value-team_type={team_type_item.team_type}
              phx-target={@phx_target}
            >
              <img src={get_team_icon_path(team_type_item.team_type)} class="ml-2 mr-2"/>
              <%= team_type_item.display_name %>
            </li>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  defp get_display_name(team_type) do
    team_type =
      @team_type_select_list
      |> Enum.find(fn team_types ->
        team_types.team_type == team_type
      end)

    team_type.display_name
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

  def show_free_trial_together_link?(user) do
    # プラン契約中でない場合にリンクを表示
    Subscriptions.get_user_subscription_user_plan(user.id)
    |> is_nil()
  end

  defp get_team_icon_path(team_type) do
    # TODO 全チーム種別のアイコンの追加、関数の実装場所の相談
    icons = @team_types
    icons[team_type]
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

  defp filter_team_type_select_list_by_user_id(user_id) do
    @team_type_select_list
    |> Enum.filter(fn team_type_item ->
      team_type_item.visiblily_check_function.(user_id)
    end)
  end
end

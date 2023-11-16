defmodule BrightWeb.TeamMemberSkillCardComponent do
  @moduledoc """
  チームメンバーのスキルカードLiveComponent
  """

  use BrightWeb, :live_component

  import BrightWeb.SkillPanelLive.SkillPanelComponents
  import BrightWeb.PathHelper
  import BrightWeb.BrightCoreComponents, only: [action_button: 1]

  alias Bright.UserProfiles
  alias Bright.SkillPanels

  @impl true
  def render(assigns) do
    ~H"""
      <div id={@id} class="flex w-full lg:w-[474px] h-[544px] lg:h-[654px] shadow flex-col bg-white relative">
      <!-- メンバーデータ -->
        <div
          :if={is_nil(@display_skill_card.user_skill_class_score)}
          class="h-[56px] bg-pureGray-600"
        >
        </div>

        <.team_member_class_tab
          :if={!is_nil(@display_skill_card.user_skill_class_score)}
          user={@display_skill_card.user}
          user_skill_class_score={@display_skill_card.user_skill_class_score}
          select_skill_class={@display_skill_card.select_skill_class}
          skill_class_tab_click_target={@myself}
        />
        <% me = @display_skill_card.user.id == @current_user.id %>
        <div class="flex px-4 lg:px-6 pt-1 items-center h-20">
          <div class="flex w-[260px] mr-2 lg:w-full flex-row text-xl h-12">
            <.link
              class="text-xl w-56 truncate lg:text-2xl font-bold"
              navigate={~p"/mypage/#{if me, do: "", else: @display_skill_card.user.name}"}
            >
              <%= @display_skill_card.user.name %>
            </.link>
            <div class="flex flex-col lg:-mt-2">
              <.link
                  :if={ !is_nil(@display_skill_card.user_skill_class_score)}
                  class="bg-white text-sm block border border-solid border-brightGreen-300 cursor-pointer font-bold lg:mx-2 my-1 py-1 rounded text-center select-none text-brightGreen-300 w-28 hover:opacity-50"
                  href={
                    skill_panel_path("graphs",@display_skill_panel, @display_skill_card.user, me, false)
                    <> "?class=#{@display_skill_card.select_skill_class.class}"
                  }
              >
                成長パネル
              </.link>

              <.link
                  :if={ !is_nil(@display_skill_card.user_skill_class_score)}
                  class="bg-white text-sm block border border-solid border-brightGreen-300 cursor-pointer font-bold lg:mx-2 my-1 py-1 rounded text-center select-none text-brightGreen-300 w-28 hover:opacity-50"
                  href={
                    skill_panel_path("panels",@display_skill_panel, @display_skill_card.user, me, false)
                    <> "?class=#{@display_skill_card.select_skill_class.class}"
                  }
              >
                スキルパネル
              </.link>
            </div>
          </div>
          <div class="mt-4">
            <img
              class="object-cover inline-block mr-2 lg:mr-5 h-[42px] w-[42px] lg:h-16 lg:w-16 rounded-full"
              src={icon_url(assigns.display_skill_card.user.user_profile.icon_file_path)}
            />
          </div>
        </div>
        <div class="ml-4 lg:ml-6 mt-1 text-base h-[12px]">
          <%= assigns.display_skill_card.user.user_profile.title %>
        </div>

        <div
          :if={ is_nil(@display_skill_card.user_skill_class_score)}
          class="w-full lg:w-[400px] h-[240px] mt-12 lg:mt-0 lg:h-[400px] flex justify-center mx-auto"
          >
          <p
            class="font-bold inline-block align-middle my-auto mx-auto justify-center"
          >
            スキル保有していません
          </p>
        </div>

        <div
          :if={ !is_nil(@display_skill_card.user_skill_class_score)}
          class="hidden lg:flex w-[400px] h-[400px] justify-center mx-auto"
          >
          <.live_component
            id={"skill-gem-#{@id}"}
            module={BrightWeb.ChartLive.SkillGemComponent}
            display_user={@display_skill_card.user}
            skill_panel={@display_skill_panel}
            class={@display_skill_card.select_skill_class.class}
            select_label={"now"}
            me={:true}
            anonymous={:false}
            root={""}
            size="md"
            display_link="false"
          />
        </div>

        <div
          :if={ !is_nil(@display_skill_card.user_skill_class_score)}
          class="lg:hidden w-full h-[200px] mt-20 flex justify-center mx-auto"
          >
          <.live_component
            id={"skill-gem-sp-#{@id}"}
            module={BrightWeb.ChartLive.SkillGemComponent}
            display_user={@display_skill_card.user}
            skill_panel={@display_skill_panel}
            class={@display_skill_card.select_skill_class.class}
            select_label={"now"}
            me={:true}
            anonymous={:false}
            root={""}
            size="sp"
            display_link="false"
          />
        </div>


        <div class="p-4 lg:p-6 pt-0 flex w-full gap-x-2 ">
          <button class="text-sm font-bold px-5 py-3 rounded text-white bg-brightGray-200">
            1on1に誘う
          </button>
          <%= if @display_skill_card.user.id == @current_user.id do %>
            <%= if !is_nil(@display_skill_panel) && is_nil(@display_skill_card.user_skill_class_score) do %>
              <.link navigate={~p"/more_skills/teams/#{@team_id}/skill_panels/#{@display_skill_panel}"}>
              <button class="text-sm font-bold px-5 py-3 rounded text-white bg-base">
                スキルを取得
              </button>
              </.link>
            <% end %>
          <% else %>
            <.link
              :if={comparable_skill_panel?(@display_skill_panel, @display_skill_card, @current_user)}
              href={
                skill_panel_path("graphs", @display_skill_panel, @current_user, true, false)
                <> "?class=#{@display_skill_card.select_skill_class.class}&compare=#{@display_skill_card.user.name}"
              }
            >
              <.action_button class="px-5 py-3">
                この人と比較
              </.action_button>
            </.link>
          <% end %>
          <button class="min-w-[124px] text-sm font-bold px-5 py-3 rounded text-white bg-brightGray-200">
            スキルアップ確認
          </button>
        </div>
      </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  @impl true
  def handle_event(
        "skill_class_tab_click",
        %{"skill_class_id" => skill_class_id},
        socket
      ) do
    #  # skill_class_tabがクリックされたユーザーを検索する
    # display_skill_cardの構造
    # select_skill_class
    # user
    # user_skill_class_score.skill_class
    # user_skill_class_score.skill_class_score

    # display_skill_classesから該当のskill_classを検索する
    clicked_skill_class =
      socket.assigns.display_skill_classes
      |> Enum.find(fn display_skill_class ->
        display_skill_class.id == skill_class_id
      end)

    display_skill_card =
      socket.assigns.display_skill_card
      |> Map.put(:select_skill_class, clicked_skill_class)

    socket = assign(socket, :display_skill_card, display_skill_card)

    {:noreply, socket}
  end

  defp icon_url(icon_file_path) do
    UserProfiles.icon_url(icon_file_path)
  end

  defp comparable_skill_panel?(skill_panel, skill_card, current_user) do
    # 「この人と比較」押下可能かどうか
    # - 「この人」にスキルスコアがあり、
    # - 自身が取得済みのスキルパネルであること
    skill_card.user_skill_class_score &&
      SkillPanels.get_user_skill_panel(current_user, skill_panel.id)
  end
end

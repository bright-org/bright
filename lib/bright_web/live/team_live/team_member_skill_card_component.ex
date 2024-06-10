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
  alias Bright.UserSearches
  alias Bright.Chats
  alias Bright.Recruits
  alias Bright.Recruits.Interview

  @impl true
  def render(assigns) do
    ~H"""
    <div
      id={@id}
      class="flex flex-col justify-between w-full lg:w-[calc(50%-8px)] 2xl:w-[calc(33.33333%-11px)] lg:min-w-[474px] h-[544px] lg:h-[654px] shadow bg-white relative"
    >
      <.team_member_class_tab
        user={@display_skill_card.user}
        user_skill_class_score={@display_skill_card.user_skill_class_score}
        select_skill_class={@display_skill_card.select_skill_class}
        skill_class_tab_click_target={@myself}
      />

      <% me = @display_skill_card.user.id == @current_user.id %>
      <div class="flex pt-2 px-4 h-20">
        <div class="flex w-full flex-row text-xl items-center justify-between">
          <div class="flex items-center">
            <div>
              <img
                class="object-cover inline-block mr-2 lg:mr-5 h-[42px] w-[42px] lg:h-16 lg:w-16 rounded-full"
                src={
                  UserProfiles.icon_url(assigns.display_skill_card.user.user_profile.icon_file_path)
                }
              />
            </div>
            <.link
              class="text-xl w-40 lg:w-56 truncate lg:text-2xl font-bold hover:opacity-50"
              navigate={~p"/mypage/#{if me, do: "", else: @display_skill_card.user.name}"}
            >
              <%= @display_skill_card.user.name %>
            </.link>
          </div>
          <div class="flex gap-x-1 lg:gap-x-2">
            <.link
              :if={!is_nil(@display_skill_card.user_skill_class_score)}
              class="h-8 bg-white flex items-center justify-center border border-solid border-brightGreen-300 px-1 rounded text-center hover:opacity-50"
              href={
                    skill_panel_path("graphs",@display_skill_panel, @display_skill_card.user, me, false)
                    <> "?class=#{@display_skill_card.select_skill_class.class}"
                  }
            >
              <div class="inline-block h-6 w-6 [mask-image:url('/images/common/icons/growthPanel.svg')] [mask-position:center_center] [mask-size:100%] [mask-repeat:no-repeat] bg-brightGreen-300" />
            </.link>

            <.link
              :if={!is_nil(@display_skill_card.user_skill_class_score)}
              class="h-8 bg-white flex items-center justify-center border border-solid border-brightGreen-300 px-1 rounded text-center hover:opacity-50"
              href={
                    skill_panel_path("panels",@display_skill_panel, @display_skill_card.user, me, false)
                    <> "?class=#{@display_skill_card.select_skill_class.class}"
                  }
            >
              <div class="inline-block h-6 w-6 [mask-image:url('/images/common/icons/skillPanel.svg')] [mask-position:center_center] [mask-size:100%] [mask-repeat:no-repeat] bg-brightGreen-300" />
            </.link>
          </div>
        </div>
      </div>

      <div class="px-4 text-base break-words">
        <%= @display_skill_card.user.user_profile.title %>
      </div>

      <div
        :if={is_nil(@display_skill_card.user_skill_class_score)}
        class="w-full lg:w-[400px] h-[240px] mt-12 lg:mt-0 lg:h-[400px] flex justify-center mx-auto"
      >
        <p class="font-bold inline-block align-middle my-auto mx-auto justify-center">
          スキル保有していません
        </p>
      </div>

      <div
        :if={!is_nil(@display_skill_card.user_skill_class_score)}
        class="hidden lg:flex w-[400px] h-[400px] justify-center mx-auto"
      >
        <.live_component
          id={"skill-gem-#{@id}"}
          module={BrightWeb.ChartLive.SkillGemComponent}
          display_user={@display_skill_card.user}
          skill_panel={@display_skill_panel}
          class={@display_skill_card.select_skill_class.class}
          select_label="now"
          me={true}
          anonymous={false}
          root=""
          size="md"
          display_link="false"
        />
      </div>

      <div
        :if={!is_nil(@display_skill_card.user_skill_class_score)}
        class="lg:hidden w-full h-[300px] flex justify-center mx-auto"
      >
        <.live_component
          id={"skill-gem-sp-#{@id}"}
          module={BrightWeb.ChartLive.SkillGemComponent}
          display_user={@display_skill_card.user}
          skill_panel={@display_skill_panel}
          class={@display_skill_card.select_skill_class.class}
          select_label="now"
          me={true}
          anonymous={false}
          root=""
          size="sp"
          display_link="false"
        />
      </div>

      <div class="pb-2 flex w-full gap-x-1 lg:gap-x-2 justify-around">
        <button
          :if={@display_skill_card.user.id != @current_user.id}
          class="flex gap-x-1 lg:gap-x-2 items-center text-xs lg:text-sm font-bold px-1 lg:px-3 py-2 rounded text-white bg-base hover:opacity-50"
          phx-click={
            if @hr_enabled,
              do:
                JS.push("start_1on1",
                  target: @myself,
                  value: %{
                    user_id: @display_skill_card.user.id,
                    skill_params: [%{skill_panel: @display_skill_panel.id, career_field: "1on1"}]
                  }
                )
          }
        >
          <div class="inline-block h-4 w-4 lg:h-6 lg:w-6 [mask-image:url('/images/common/icons/oneOnOneInvitation.svg')] [mask-position:center_center] [mask-size:100%] [mask-repeat:no-repeat] bg-white" />
          1on1に誘う
        </button>
        <%= if @display_skill_card.user.id == @current_user.id do %>
          <%= if !is_nil(@display_skill_panel) && is_nil(@display_skill_card.user_skill_class_score) do %>
            <.link navigate={~p"/more_skills/teams/#{@team_id}/skill_panels/#{@display_skill_panel}"}>
              <button class="flex gap-x-1 lg:gap-x-2 items-center text-xs lg:text-sm font-bold px-1 lg:px-3 py-2 rounded text-white bg-base hover:opacity-50">
                <div class={[
                  "inline-block h-4 w-4 lg:h-6 lg:w-6 [mask-image:url('/images/common/icons/skillSelect.svg')] [mask-position:center_center] [mask-size:100%] [mask-repeat:no-repeat] bg-white"
                ]} /> スキルを取得
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
            <.action_button class="flex gap-x-1 lg:gap-x-2 items-center px-1 lg:px-3 py-2">
              <div class={[
                "inline-block h-4 w-4 lg:h-6 lg:w-6 [mask-image:url('/images/common/icons/switchIndividual.svg')] [mask-position:center_center] [mask-size:100%] [mask-repeat:no-repeat] bg-base"
              ]} /> この人と比較
            </.action_button>
          </.link>
        <% end %>
        <button class="flex gap-x-1 lg:gap-x-2 items-center text-xs lg:text-sm font-bold px-1 lg:px-3 py-2 rounded text-white bg-brightGray-200">
          <div class="inline-block h-4 w-4 lg:h-6 lg:w-6 [mask-image:url('/images/common/icons/skillUp.svg')] [mask-position:center_center] [mask-size:100%] [mask-repeat:no-repeat] bg-white" />
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

  def handle_event("start_1on1", %{"skill_params" => skill_params, "user_id" => user_id}, socket) do
    recruiter = socket.assigns.current_user
    chat = Recruits.find_or_create(skill_params, recruiter.id, user_id)

    {:noreply, push_navigate(socket, to: ~p"/recruits/chats/#{chat.id}")}
  end

  defp comparable_skill_panel?(skill_panel, skill_card, current_user) do
    # 「この人と比較」押下可能かどうか
    # - 「この人」にスキルスコアがあり、
    # - 自身が取得済みのスキルパネルであること
    skill_card.user_skill_class_score &&
      SkillPanels.get_user_skill_panel(current_user, skill_panel.id)
  end
end

defmodule BrightWeb.TeamMemberSkillCardComponent do
  @moduledoc """
  チームメンバーのスキルカードLiveComponent
  """

  use BrightWeb, :live_component

  import BrightWeb.SkillPanelLive.SkillPanelComponents
  alias Bright.UserProfiles

  @impl true
  def render(assigns) do
    ~H"""
      <div class="flex w-full lg:w-[474px] h-[514px] lg:h-[654px] shadow flex-col bg-white relative">
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
          skill_class_tab_click_target={assigns.myself}
        />

        <div class="flex justify-between px-4 lg:px-6 pt-1 items-center">
          <div class="text-xl w-56 truncate lg:w-full lg:text-2xl font-bold">
            <%= assigns.display_skill_card.user.name %>
          </div>
          <div class="mt-4">
            <img
              class="object-cover inline-block mr-2 lg:mr-5 h-[42px] w-[42px] lg:h-16 lg:w-16 rounded-full"
              src={icon_url(assigns.display_skill_card.user.user_profile.icon_file_path)}
            />
          </div>
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


        <div class="p-4 lg:p-6 pt-0 flex w-full gap-x-2 lg:justify-between ">
          <button class="text-sm font-bold px-5 py-3 rounded text-white bg-brightGray-200">
            1on1に誘う
          </button>
          <button class="text-sm font-bold px-5 py-3 rounded text-white bg-brightGray-200">
            この人と比較
          </button>
          <button class="text-sm font-bold px-5 py-3 rounded text-white bg-brightGray-200">
            スキルアップ確認
          </button>
        </div>
        <div class="w-full text-center absolute bottom-1">
        βリリース（10月予定）で利用可能になります
        </div>
      </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)

    {:ok, socket}
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

    socket =
      socket
      |> assign(:display_skill_card, display_skill_card)

    {:noreply, socket}
  end

  defp icon_url(icon_file_path) do
    UserProfiles.icon_url(icon_file_path)
  end
end

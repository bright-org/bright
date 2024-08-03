defmodule BrightWeb.MypageLive.Index do
  use BrightWeb, :live_view

  import BrightWeb.ProfileComponents
  import BrightWeb.ChartComponents
  import BrightWeb.BrightModalComponents, only: [bright_modal: 1]

  alias Phoenix.LiveView.JS
  alias Bright.SkillUnits
  alias Bright.SkillEvidences
  alias Bright.UserProfiles
  alias Bright.SkillScores
  alias Bright.Teams
  alias BrightWeb.PathHelper
  alias BrightWeb.DisplayUserHelper

  def mount(params, _session, socket) do
    socket
    |> DisplayUserHelper.assign_display_user(params)
    |> assign(:page_title, "保有スキル")
    |> then(&{:ok, &1})
  end

  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> assign_skillset_gem()
     |> assign_recent_level_up_skill_classes()
     |> assign_recent_skill_evidences()
     |> assign_related_user_ids()
     |> assign_recent_others_skill_evidences()
     |> apply_action(socket.assigns.live_action, params)}
  end

  def handle_event("edit_skill_evidence", %{"id" => id}, socket) do
    skill_evidence = SkillEvidences.get_skill_evidence!(id)
    skill = SkillUnits.get_skill!(skill_evidence.skill_id)

    # モーダルを開き、表示内容を選択した学習メモで初期化する
    # モーダルを閉じたときは、一覧を最新にしている
    send_update(BrightWeb.ModalComponent,
      id: "skill-evidence-modal",
      open: true,
      on_open: fn ->
        send_update(BrightWeb.SkillPanelLive.SkillEvidenceComponent,
          id: "skill-evidence",
          reset: true,
          skill_evidence: skill_evidence,
          skill: skill,
          user: socket.assigns.current_user
        )
      end,
      on_close: fn ->
        send(self(), :reload_recent_skill_evidences)
      end
    )

    {:noreply, socket}
  end

  def handle_info(:reload_recent_skill_evidences, socket) do
    {:noreply, assign_recent_skill_evidences(socket)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "保有スキル")
    |> assign(:search, false)
  end

  defp apply_action(socket, :search, _params) do
    socket
    |> assign(:page_title, "スキル検索／スカウト")
    |> assign(:search, true)
  end

  defp apply_action(socket, :free_trial, params) do
    plan = Map.get(params, "plan", "hr_plan")

    socket
    |> assign(:page_title, "無料トライアル")
    |> assign(:plan, plan)
    |> assign(:search, false)
  end

  defp assign_skillset_gem(socket) do
    skillset_gem =
      SkillScores.get_skillset_gem(socket.assigns.display_user.id)
      |> Enum.sort_by(& &1.position, :asc)
      |> Enum.map(&[&1.name, floor(&1.percentage)])
      |> Enum.zip_reduce([], &(&2 ++ [&1]))
      |> then(fn
        [] -> nil
        [names, percentags] -> %{labels: names, data: percentags}
      end)

    assign(socket, :skillset_gem, skillset_gem)
  end

  defp assign_recent_level_up_skill_classes(socket) do
    %{display_user: display_user} = socket.assigns

    recent_level_up_skill_class_scores =
      SkillScores.list_recent_level_up_skill_class_scores(display_user)

    assign(socket, :recent_level_up_skill_class_scores, recent_level_up_skill_class_scores)
  end

  defp assign_recent_skill_evidences(socket) do
    %{display_user: display_user} = socket.assigns

    # 必要に応じてstream化のこと
    recent_skill_evidences =
      SkillEvidences.list_recent_skill_evidences([display_user.id])
      |> Bright.Repo.preload(skill_evidence_posts: [user: [:user_profile]])

    assign(socket, :recent_skill_evidences, recent_skill_evidences)
  end

  defp assign_related_user_ids(socket) do
    %{current_user: user} = socket.assigns
    assign(socket, :related_user_ids, Teams.list_user_ids_related_team_by_user(user))
  end

  defp assign_recent_others_skill_evidences(%{assigns: %{me: true}} = socket) do
    %{related_user_ids: related_user_ids} = socket.assigns

    # 必要に応じてstream化のこと
    recent_others_skill_evidences =
      SkillEvidences.list_recent_skill_evidences(related_user_ids)
      |> Bright.Repo.preload(skill_evidence_posts: [user: [:user_profile]])
      |> Enum.filter(fn skill_evidence ->
        # メモ所有者本人の投稿があることを前提とする
        Enum.find(skill_evidence.skill_evidence_posts, &(&1.user_id == skill_evidence.user_id))
      end)

    assign(socket, :recent_others_skill_evidences, recent_others_skill_evidences)
  end

  defp assign_recent_others_skill_evidences(socket) do
    # 他者表示のときは使用しない
    assign(socket, :recent_others_skill_evidences, nil)
  end

  defp js_show_my_field(js \\ %JS{}) do
    js
    |> JS.remove_class("button-toggle-active", to: "#btn-others-field")
    |> JS.hide(to: "#others-field")
    |> JS.add_class("button-toggle-active")
    |> JS.show(to: "#my-field")
  end

  defp js_show_others_field(js \\ %JS{}) do
    js
    |> JS.remove_class("button-toggle-active", to: "#btn-my-field")
    |> JS.hide(to: "#my-field")
    |> JS.add_class("button-toggle-active")
    |> JS.show(to: "#others-field")
  end

  # local components
  # ---

  defp skill_ups(assigns) do
    ~H"""
    <section>
      <h5 class="text-base lg:text-lg">スキルアップ</h5>
      <div
        :if={@recent_level_up_skill_class_scores == []}
        class="bg-white rounded-md mt-1 px-2 py-0.5 text-sm font-medium gap-y-2 flex py-2 my-2"
      >
        まだスキルを選択していません
      </div>

      <div class="bg-white rounded-md mt-1 px-2 py-0.5">
        <ul class="text-sm font-medium text-center gap-y-2">
          <li
            :for={skill_class_score <- @recent_level_up_skill_class_scores}
            class="flex flex-wrap my-2"
          >
            <.link
              class="cursor-pointer hover:filter hover:brightness-[80%] text-left flex flex-wrap items-center text-base px-1 py-1 flex-1 mr-4 w-full lg:w-auto lg:flex-nowrap"
              href={skill_panel_path(skill_class_score, @display_user, @me, @anonymous)}
            >
              <img src="/images/common/icons/skill.svg" class="w-6 h-6 mr-2.5">
              <span class="order-3 lg:order-2 flex-1 mr-2">
                <%= skill_up_message(skill_class_score) %>
              </span>
            </.link>
          </li>
        </ul>
      </div>
    </section>
    """
  end

  defp skill_evidences(assigns) do
    ~H"""
    <section>
      <h5 class="text-base lg:text-lg">学習メモ</h5>
      <div
        :if={@recent_skill_evidences == []}
        class="bg-white rounded-md mt-1 px-2 py-0.5 text-sm font-medium gap-y-2 flex py-2 my-2"
      >
        まだ学習メモがありません
      </div>

      <div
        :for={skill_evidence <- @recent_skill_evidences}
        class="bg-white rounded-md mt-1 px-2 py-0.5 text-sm font-medium gap-y-2 flex py-2 my-2"
      >
        <.skill_evidence
          skill_evidence={skill_evidence}
          skill_evidence_post={get_latest_skill_evidence_post(skill_evidence)}
          skill_breadcrumb={SkillEvidences.get_skill_breadcrumb(%{id: skill_evidence.skill_id})}
          current_user={@current_user}
          anonymous={@anonymous}
          related_user_ids={@related_user_ids}
          display_time={true}
        />
      </div>
    </section>
    """
  end

  defp others_skill_evidences(assigns) do
    ~H"""
    <section>
      <h5 class="text-base lg:text-lg">いま学んでいます</h5>
      <div
        :for={skill_evidence <- @recent_others_skill_evidences}
        class="bg-white rounded-md mt-1 px-2 py-0.5 text-sm font-medium gap-y-2 flex py-2 my-2"
      >
        <.skill_evidence
          skill_evidence={skill_evidence}
          skill_evidence_post={get_latest_my_skill_evidence_post(skill_evidence)}
          skill_breadcrumb={SkillEvidences.get_skill_breadcrumb(%{id: skill_evidence.skill_id})}
          current_user={@current_user}
          anonymous={@anonymous}
          related_user_ids={@related_user_ids}
          display_time={false}
        />
      </div>
      <div class="bg-white rounded-md mt-1 px-2 py-0.5 text-sm font-medium gap-y-2 flex py-2 my-2">
        <.link navigate={~p"/notifications/evidences"}>
          「学習メモのヘルプ」をみる
        </.link>
      </div>
    </section>
    """
  end

  defp skill_evidence(assigns) do
    ~H"""
    <%# アイコン表示 %>
    <div class="flex-none text-center pt-4 mx-2">
      <% my_post? = @current_user.id == @skill_evidence_post.user_id %>
      <% anonymous? = @anonymous || @skill_evidence_post.user_id not in @related_user_ids %>

      <%= if my_post? do %>
        <img class="h-10 w-10 rounded-full" src={icon_file_path(@current_user, false)} />
      <% else %>
        <.link navigate={PathHelper.mypage_path(@skill_evidence_post.user, anonymous?)}>
          <img class="h-10 w-10 rounded-full" src={icon_file_path(@skill_evidence_post.user, anonymous?)} />
        </.link>
      <% end %>
    </div>

    <%# 投稿表示 %>
    <div class="grow flex flex-col gap-y-2 mx-2">
      <div class="text-xs flex justify-between">
        <p class="font-bold"><%= @skill_breadcrumb %></p>
        <div
          :if={@display_time}
          id={"timestamp-#{@skill_evidence_post.id}"}
          phx-hook="LocalTime"
          phx-update="ignore"
          data-iso={NaiveDateTime.to_iso8601(@skill_evidence_post.inserted_at)}
          >
          <p class="hidden lg:block" data-local-time="%x %H:%M"></p>
        </div>
      </div>
      <p class="break-all">
        <%= SkillEvidences.truncate_post_content(@skill_evidence_post.content, 200) %>
      </p>
      <nav class="flex items-center gap-x-4">
        <button
          class="link-evidence"
          phx-click="edit_skill_evidence"
          phx-value-id={@skill_evidence.id}
        >
          <img src="/images/common/icons/skillEvidenceActive.svg">
        </button>
      </nav>
    </div>
    """
  end

  defp skill_panel_path(skill_class_score, display_user, me, anonymous) do
    %{skill_class: %{class: class, skill_panel: skill_panel}} = skill_class_score

    PathHelper.skill_panel_path("graphs", skill_panel, display_user, me, anonymous) <>
      "?class=#{class}"
  end

  defp skill_up_message(skill_class_score) do
    %{
      level: level,
      skill_class: %{
        name: skill_class_name,
        class: class,
        skill_panel: %{
          name: skill_panel_name
        }
      }
    } = skill_class_score

    level_name = Gettext.gettext(BrightWeb.Gettext, "level_#{level}")

    case {class, level} do
      {1, :beginner} ->
        "#{skill_panel_name}【#{skill_class_name}】を始めました"

      _ ->
        "#{skill_panel_name}【#{skill_class_name}】が「#{level_name}」にレベルアップしました"
    end
  end

  defp get_latest_skill_evidence_post(skill_evidence) do
    skill_evidence.skill_evidence_posts
    |> Enum.sort_by(& &1.inserted_at, {:desc, NaiveDateTime})
    |> List.first()
  end

  defp get_latest_my_skill_evidence_post(skill_evidence) do
    # 「いま学んでいます」では自分自身の最新投稿を参照する
    skill_evidence.skill_evidence_posts
    |> Enum.sort_by(& &1.inserted_at, {:desc, NaiveDateTime})
    |> Enum.find(&(&1.user_id == skill_evidence.user_id))
  end

  defp icon_file_path(_user, true), do: UserProfiles.icon_url(nil)

  defp icon_file_path(user, _anonymous) do
    UserProfiles.icon_url(user.user_profile.icon_file_path)
  end
end

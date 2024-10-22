defmodule BrightWeb.SearchLive.ResultComponents do
  alias Bright.UserJobProfiles.UserJobProfile
  use BrightWeb, :component

  import BrightWeb.ChartComponents, only: [doughnut_graph: 1]
  import BrightWeb.DisplayUserHelper, only: [encrypt_user_name: 1]
  import BrightWeb.PathHelper

  import BrightWeb.SkillPanelLive.SkillPanelComponents,
    only: [profile_skill_class_level: 1, score_mark_class: 2, skill_score_percentages: 2]

  alias Bright.SkillScores
  alias Bright.SkillEvidences
  alias Bright.SkillReferences
  alias Bright.SkillExams

  def job_area(assigns) do
    ~H"""
    <div class="w-[380px] text-start">
      <p class="mb-2">
        <span>　希望年収：</span>
        <span><%= if @job.desired_income, do: "#{@job.desired_income} 万円以上", else: "-" %></span>
      </p>

      <%= if @job.office_work do %>
      <p class="mb-2 ">
        <span>　　　出勤：可<%= if @job.office_working_hours, do: "　#{@job.office_working_hours}" %>　土日祝<%= enable?(@job.office_work_holidays)%></span>
      </p>
      <p class="mb-2">
        <span>希望勤務地：<%= @job.office_pref %></span>
      </p>
      <% else %>
      <p class="mb-2">
        <span>　　　出勤：不可</span>
      </p>
      <% end %>

      <p class="mb-2">
        <%= if @job.remote_work do %>
          <span>　リモート：可<%= if @job.remote_working_hours, do: "　#{@job.remote_working_hours}" %>　土日祝<%= enable?(@job.remote_work_holidays)%></span>
        <% else %>
          <span>　リモート：不可</span>
        <% end %>
      </p>

      <p class="mb-4">
        <span>　業務可否：<%= UserJobProfile.wish_job_type(@job) %></span>
      </p>
      <p class="border-t border-brightGray-200 mb-2 mt-2 pt-2 pl-2">
        <span>スキルの最終更新日：</span>
        <span><%=
          if @last_updated,
          do: NaiveDateTime.to_date(@last_updated),
          else: "-"
        %></span>
      </p>
    </div>
    """
  end

  def doughnut_area(assigns) do
    ~H"""
    <div class="ml-2 mt-8 ">
      <div class="flex w-[180px]">
        <div class="h-24 overflow-hidden w-[80px]">
          <.doughnut_graph
            id={"doughnut-graph-single-sample-#{@index}"}
            data={skill_score_percentages(@counter, @num_skills)}
          />
        </div>
        <div class="h-24 overflow-hidden w-[100px]">
          <div class="h-20 ml-2 flex flex-wrap">
            <p class="text-brightGreen-300 font-bold w-full flex mt-1 mb-1">
              <.profile_skill_class_level level={@skill_class_score.level} />
            </p>

            <div class="flex flex-col w-24 pl-6">
              <div class="min-w-[4em] flex items-center">
                <span class={[score_mark_class(:high, :green), "inline-block mr-1"]}></span>
                <%= SkillScores.calc_high_skills_percentage(@counter.high, @num_skills) %>％
              </div>
              <div class="min-w-[4em] flex items-center mt-1">
                <span class={[score_mark_class(:middle, :green), "inline-block mr-1"]}></span>
                <%= SkillScores.calc_middle_skills_percentage(@counter.middle, @num_skills) %>％
              </div>
            </div>
          </div>
        </div>
      </div>
      <ul class="text-xs w-40 text-start">
        <li>
          <p>
            <span class="inline-block w-28">学習メモの登録率</span>
            <span><%= SkillEvidences.calc_filled_percentage(@counter.evidence_filled, @num_skills) %>%</span>
          </p>
        </li>

        <li>
          <p>
            <span class="inline-block w-28">教材の学習率</span>
            <span><%= SkillReferences.calc_read_percentage(@counter.reference_read, @num_skills) %>%</span>
          </p>
        </li>

        <li>
          <p>
            <span class="inline-block w-28">試験の受験率</span>
            <span><%= SkillExams.calc_touch_percentage(@counter.exam_touch, @num_skills) %>%</span>
          </p>
        </li>
      </ul>
    </div>
    """
  end

  def action_area(assigns) do
    ~H"""
    <div class="border-l border-brightGray-200 border-dashed ml-2 pl-2 w-28">
      <%= if @user.id in @stock_user_ids do %>
        <p class="mb-2 justify-center text-gray-300 bg-white px-2 py-1 inline-flex font-medium rounded-md text-sm items-center border border-gray-300 w-28 cursor-default">
          <span
            class="material-symbols-outlined md-18 mr-1 text-gray-300"
          >inventory</span>
          ストック
        </p>
      <% else %>
      <button
        type="button"
        phx-click={JS.push("stock", value: %{
          params: %{user_id: @user.id, skill_panel: @skill_panel.skill_panel_name, desired_income: @user.user_job_profile.desired_income}
        }, target: "#skill_search_modal")}
        class="mb-2 justify-center text-gray-900 bg-white px-2 py-1 inline-flex font-medium rounded-md text-sm items-center border border-brightGray-200 group w-28"
      >
        <span
          class="material-symbols-outlined md-18 mr-1 text-brightGray-600"
        >inventory</span>
        ストック
      </button>
      <% end %>
      <.link
        class="bg-white block border border-solid border-brightGreen-300 cursor-pointer mb-2 px-4 py-1 rounded select-none text-center text-brightGreen-300 font-bold w-28 hover:filter hover:brightness-[80%]"
        target="_blank"
        rel="noopener noreferrer"
        href={if (@anon), do: skill_panel_path("graphs",%{id: @skill_panel.skill_panel}, %{name_encrypted: encrypt_user_name(@user)},false,true)
          <> "?class=#{@skill_panel.class}",
          else: skill_panel_path("graphs",%{id: @skill_panel.skill_panel}, @user,false,false)
          <> "?class=#{@skill_panel.class}"
        }
      >
        成長パネル
      </.link>
      <.link
        class="bg-white block border border-solid border-brightGreen-300 cursor-pointer px-4 py-1 rounded select-none text-center text-brightGreen-300 font-bold w-28 hover:filter hover:brightness-[80%]"
        target="_blank"
        rel="noopener noreferrer"
        href={if (@anon), do: "/mypage/anon/#{encrypt_user_name(@user)}", else: "/mypage/#{@user.name}"
          }
      >
        保有スキル
      </.link>
    </div>
    """
  end

  defp enable?(true), do: "可"
  defp enable?(false), do: "不可"
end

defmodule BrightWeb.SkillPanelLive.SkillsCardComponent do
  # スキルパネル画面 スキル一覧を表示するコンポーネント
  # タイムライン操作に基づいて適当なスキル一覧の表示を行う
  #
  # （スキルスコア入力に関しては、LiveViewで行いこちらでは制御しない）

  use BrightWeb, :live_component

  import BrightWeb.SkillPanelLive.SkillsComponents

  alias BrightWeb.BrightCoreComponents

  def render(assigns) do
    ~H"""
    <div id={@id} class="mt-0 lg:mt-4">
      <BrightCoreComponents.flash_group flash={@inner_flash} />

      <div class="px-6 mt-4 lg:mt-8">
        <.skills_card
          skill_units={@current_skill_units}
          skill_panel={@skill_panel}
          skill_score_dict={@current_skill_score_dict}
          path={@path}
          query={@query}
          display_user={@display_user}
          current_skill_dict={@current_skill_dict}
          current_skill_score_dict={@current_skill_score_dict}
          myself={@myself}
          me={@me}
          anonymous={@anonymous}
        />
      </div>
    </div>
    """
  end

  def mount(socket) do
    {:ok,
     socket
     |> assign(skill_class: nil)
     |> clear_inner_flash()}
  end

  def update(assigns, socket) do
    {:ok, assign_assigns_with_current_if_updated(socket, assigns)}
  end

  defp assign_assigns_with_current_if_updated(socket, assigns) do
    # 基本的には assigns をアサインするのみ
    # ただし、表示上「現在」の情報を必要とするため、スキルクラスが更新されている場合には「現在」の情報を更新する
    prev_skill_class = socket.assigns.skill_class
    new_skill_class = assigns.skill_class

    if prev_skill_class == new_skill_class do
      socket
      |> assign(assigns)
    else
      socket
      |> assign(assigns)
      |> assign_current_skill_units()
      |> assign_current_skill_dict()
    end
  end

  defp assign_current_skill_units(socket) do
    skill_units =
      socket.assigns.skill_class
      |> Bright.Repo.preload(
        skill_units: [skill_categories: [skills: [:skill_reference, :skill_exam]]]
      )
      |> Map.get(:skill_units)

    skills =
      skill_units
      |> Enum.flat_map(& &1.skill_categories)
      |> Enum.flat_map(& &1.skills)

    socket
    |> assign(current_skill_units: skill_units)
    |> assign(current_skills: skills)
  end

  defp assign_current_skill_dict(socket) do
    current_skill_dict =
      socket.assigns.current_skills
      |> Map.new(&{&1.trace_id, &1})

    socket
    |> assign(current_skill_dict: current_skill_dict)
  end

  defp clear_inner_flash(socket) do
    assign(socket, :inner_flash, %{})
  end
end

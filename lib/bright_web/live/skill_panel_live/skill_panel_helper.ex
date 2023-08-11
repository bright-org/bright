defmodule BrightWeb.SkillPanelLive.SkillPanelHelper do
  alias Bright.SkillPanels
  import Phoenix.Component, only: [assign: 3]

  def assign_skill_panel(socket, "dummy_id") do
    # TODO dummy_idはダミー用で実装完了後に消すこと
    skill_panel =
      SkillPanels.list_skill_panels()
      |> Enum.sort_by(& &1.inserted_at, {:desc, NaiveDateTime})
      |> List.first()

    assign_skill_panel(socket, skill_panel.id)
  end

  def assign_skill_panel(socket, skill_panel_id) do
    current_user = socket.assigns.current_user

    skill_panel =
      SkillPanels.get_skill_panel!(skill_panel_id)
      |> Bright.Repo.preload(
        skill_classes: [skill_class_scores: Ecto.assoc(current_user, :skill_class_scores)]
      )

    socket
    |> assign(:skill_panel, skill_panel)
  end

  def assign_skill_class_and_score(socket, nil), do: assign_skill_class_and_score(socket, "1")

  def assign_skill_class_and_score(socket, class) do
    class = String.to_integer(class)
    skill_class = socket.assigns.skill_panel.skill_classes |> Enum.find(&(&1.class == class))
    # List.first(): preload時に絞り込んでいるためfirstで取得可能
    skill_class_score = skill_class.skill_class_scores |> List.first()

    socket
    |> assign(:skill_class, skill_class)
    |> assign(:skill_class_score, skill_class_score)
  end

  def assign_page_sub_title(socket) do
    socket
    |> assign(:page_sub_title, socket.assigns.skill_panel.name)
  end
end

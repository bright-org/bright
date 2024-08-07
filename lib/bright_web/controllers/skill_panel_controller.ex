defmodule BrightWeb.SkillPanelController do
  use BrightWeb, :controller

  alias Bright.UserSkillPanels
  alias Bright.SkillPanels

  def get_skill_panel(conn, %{"skill_panel_id" => skill_panel_id}) do
    panel = SkillPanels.get_skill_panel!(skill_panel_id)

    UserSkillPanels.create_user_skill_panel(%{
      user_id: conn.assigns.current_user.id,
      skill_panel_id: panel.id
    })

    redirect(conn, to: ~p"/panels/#{panel.id}")
  end
end

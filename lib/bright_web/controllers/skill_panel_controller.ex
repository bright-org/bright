defmodule BrightWeb.SkillPanelController do
  use BrightWeb, :controller

  alias Bright.UserSkillPanels
  alias Bright.SkillPanels

  def get_skill_panel(conn, %{"skill_panel_id" => skill_panel_id}) do
    panel = SkillPanels.get_skill_panel!(skill_panel_id)

    case UserSkillPanels.user_skill_panel_exists?(
           conn.assigns.current_user.id,
           panel.id
         ) do
      true ->
        redirect(conn, to: ~p"/panels/#{panel.id}")

      false ->
        conn
        |> put_flash(:info, "スキルパネル:#{panel.name}を取得しました")
        |> redirect(to: ~p"/panels/#{panel.id}")
    end
  end
end

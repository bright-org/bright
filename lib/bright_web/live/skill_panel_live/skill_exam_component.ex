defmodule BrightWeb.SkillPanelLive.SkillExamComponent do
  use BrightWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id}>
      <%= @skill.name %> の試験エリア
    </div>
    """
  end
end

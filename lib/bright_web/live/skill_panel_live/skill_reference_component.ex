defmodule BrightWeb.SkillPanelLive.SkillReferenceComponent do
  use BrightWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id}>
      <%= @skill.name %> の教材エリア
    </div>
    """
  end
end

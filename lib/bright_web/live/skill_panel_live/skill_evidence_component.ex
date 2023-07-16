defmodule BrightWeb.SkillPanelLive.SkillEvidenceComponent do
  use BrightWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id}>
      <%= @skill.name %> のエビデンス登録エリア
    </div>
    """
  end
end

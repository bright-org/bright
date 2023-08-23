defmodule Bright.JobSkillPanelFactory do
  @moduledoc """
  Factory for Bright.Jobs.JobSkillPanel
  """

  defmacro __using__(_opts) do
    quote do
      def job_skill_panel_factory do
        %Bright.Jobs.JobSkillPanel{}
      end
    end
  end
end

defmodule Bright.SkillEvidenceFactory do
  @moduledoc """
  Factory for Bright.SkillEvidences.SkillEvidence
  """

  defmacro __using__(_opts) do
    quote do
      def skill_evidence_factory do
        %Bright.SkillEvidences.SkillEvidence{}
      end
    end
  end
end

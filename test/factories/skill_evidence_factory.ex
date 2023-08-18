defmodule Bright.SkillEvidenceFactory do
  @moduledoc """
  Factory for Bright.SkillEvidences.SkillEvidence
  """

  alias Bright.SkillEvidences.SkillEvidence

  defmacro __using__(_opts) do
    quote do
      def skill_evidence_factory do
        %SkillEvidence{
          user: build(:user),
          skill: build(:skill),
          progress: Enum.random(Ecto.Enum.values(SkillEvidence, :progress))
        }
      end
    end
  end
end

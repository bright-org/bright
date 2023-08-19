defmodule Bright.SkillEvidencePostFactory do
  @moduledoc """
  Factory for Bright.SkillEvidences.SkillEvidencePost
  """

  defmacro __using__(_opts) do
    quote do
      def skill_evidence_post_factory do
        %Bright.SkillEvidences.SkillEvidencePost{
          content: Faker.Lorem.paragraph()
        }
      end
    end
  end
end

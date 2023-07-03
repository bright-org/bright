defmodule Storybook.SkillScoreComponents.SkillGem do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.BrightWeb.SkillScoreComponents.skill_set_gem/1

  def variations do
    [
      %Variation{
        id: :skill_set4,
        attributes: %{
          data: [[90, 80, 75, 60]],
          labels: ["エンジニア", "マーケター", "デザイナー", "インフラ"]
        }
      }
    ]
  end
end

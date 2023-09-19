defmodule Bright.HistoricalSkillUnitScore do
  @moduledoc """
  The HistoricalSkillUnitScore context.

  # TODO 「公開」はSkillScoresコンテキストにまとめている。
  # 過去分だけスキルユニット専用のHistoricalSkillUnitScore(s)コンテキストを作るのは統一感がないので相談の上、対応を統合する。
  """
  import Ecto.Query, warn: false
  alias Bright.Repo
  alias Bright.HistoricalSkillUnits.HistoricalSkillUnit
  alias Bright.HistoricalSkillScores.HistoricalSkillUnitScore

  @doc """
  Returns the list of historical_skill_unit_score.

  ## Examples

      iex> get_historical_skill_gem(user_id, skill_panel_id, class, locked_date)
      [
        %{
          name: "1-スキルユニット(class:1)",
          percentage: 22.22222222222222,
          position: 1
        }
      ]

  """
  def get_historical_skill_gem(user_id, skill_panel_id, class, locked_date) do
    # TODO: スキル構造側から取得しているため-3か月している。決まり事とはいえハードコーディングのため解消する。ここかあるいは呼び出しもとでlocked_dateを適切につくる。過去参照の別タスクで対応
    locked_date =
      {locked_date.year, locked_date.month, 1}
      |> Date.from_erl!()
      |> Timex.shift(months: -3)

    # TODO 現在は重複したデータ（該当月に２回以上実施）に未対応
    from(historical_skill_unit in HistoricalSkillUnit,
      join: historical_skill_classes in assoc(historical_skill_unit, :historical_skill_classes),
      join:
        historical_skill_class_units in assoc(
          historical_skill_unit,
          :historical_skill_class_units
        ),
      on: historical_skill_classes.class == ^class,
      on: historical_skill_classes.skill_panel_id == ^skill_panel_id,
      on: historical_skill_class_units.historical_skill_unit_id == historical_skill_unit.id,
      where: historical_skill_unit.locked_date == ^locked_date,
      order_by: historical_skill_class_units.position,
      preload: [
        historical_skill_class_units: historical_skill_class_units,
        historical_skill_unit_scores: ^HistoricalSkillUnitScore.user_id_query(user_id)
      ]
    )
    |> Repo.all()
    |> Enum.uniq_by(& &1.trace_id)
    |> Enum.map(fn historical_skill_unit ->
      historical_skill_unit_score = List.first(historical_skill_unit.historical_skill_unit_scores)
      historical_skill_class_unit = List.first(historical_skill_unit.historical_skill_class_units)

      %{
        name: historical_skill_unit.name,
        percentage: Map.get(historical_skill_unit_score || %{}, :percentage, 0.0),
        position: Map.get(historical_skill_class_unit, :position)
      }
    end)
  end
end

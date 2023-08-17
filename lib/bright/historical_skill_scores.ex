defmodule Bright.HistoricalSkillScores do
  @moduledoc """
  The HistoricalSkillScores context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.HistoricalSkillUnits
  alias Bright.HistoricalSkillScores.HistoricalSkillScore

  @doc """
  Returns the list of historical_skill_scores.

  ## Examples

      iex> list_historical_skill_scores()
      [%HistoricalSkillScore{}, ...]

  """
  def list_historical_skill_scores(query \\ HistoricalSkillScore) do
    query
    |> Repo.all()
  end

  @doc """
  Returns the list of historical_skill_scores from historical_skill_class_score
  """
  def list_historical_skill_scores_from_historical_skill_class_score(%{
        historical_skill_class_id: historical_skill_class_id,
        user_id: user_id
      }) do
    HistoricalSkillUnits.list_historical_skills_on_historical_skill_class(%{
      id: historical_skill_class_id
    })
    |> Repo.preload(historical_skill_scores: HistoricalSkillScore.user_id_query(user_id))
    |> Enum.flat_map(& &1.historical_skill_scores)
  end

  @doc """
  Returns the list of historical_skill_scores from user and historical_skill_ids
  """
  def list_user_historical_skill_scores_from_historical_skill_ids(user, historical_skill_ids) do
    HistoricalSkillScore.user_id_query(user.id)
    |> HistoricalSkillScore.historical_skill_ids_query(historical_skill_ids)
    |> list_historical_skill_scores()
  end
end

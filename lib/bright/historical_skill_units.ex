defmodule Bright.HistoricalSkillUnits do
  @moduledoc """
  The HistoricalSkillUnits context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.HistoricalSkillUnits.HistoricalSkillUnit
  alias Bright.HistoricalSkillUnits.HistoricalSkill

  @doc """
  Returns the list of historical_skill_units.

  ## Examples

      iex> list_historical_skill_units()
      [%HistoricalSkillUnit{}, ...]

  """
  def list_historical_skill_units(query \\ HistoricalSkillUnit) do
    Repo.all(query)
  end

  @doc """
  Gets a single historical_skill_unit.

  Raises `Ecto.NoResultsError` if the Skill unit does not exist.

  ## Examples

      iex> get_historical_skill_unit!(123)
      %HistoricalSkillUnit{}

      iex> get_historical_skill_unit!(456)
      ** (Ecto.NoResultsError)

  """
  def get_historical_skill_unit!(id), do: Repo.get!(HistoricalSkillUnit, id)

  @doc """
  Returns the list of historical_skills

  ## Examples

      iex> list_historical_skills()
      [%HistoricalSkil{}, ...]

  """
  def list_historical_skills(query \\ HistoricalSkill) do
    Repo.all(query)
  end

  @doc """
  Gets historical_skills on historical_skill_class
  """
  def list_historical_skills_on_historical_skill_class(historical_skill_class) do
    HistoricalSkill.historical_skill_class_query(historical_skill_class.id)
    |> list_historical_skills()
  end
end

defmodule Bright.HistoricalSkillPanels do
  @moduledoc """
  The HistoricalSkillPanels context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.HistoricalSkillPanels.SkillPanel
  alias Bright.HistoricalSkillPanels.HistoricalSkillClass

  @doc """
  Returns the list of skill_panels.

  ## Examples

      iex> list_skill_panels()
      [%SkillPanel{}, ...]

  """
  def list_skill_panels do
    Repo.all(SkillPanel)
  end

  @doc """
  Gets a single skill_panel.

  Raises `Ecto.NoResultsError` if the Skill panel does not exist.

  ## Examples

      iex> get_skill_panel!(123)
      %SkillPanel{}

      iex> get_skill_panel!(456)
      ** (Ecto.NoResultsError)

  """
  def get_skill_panel!(id), do: Repo.get!(SkillPanel, id)

  @doc """
  スキルパネル＋日付条件に該当する過去スキルクラスを返す。

  locked_dateはあくまでロックした日付のため（その日以降も使われる）、
  引数date時点のスキルクラスを取るには、その３か月前のlocked_dateをみる必要がある。
  """
  def get_historical_skill_class_on_date(
        skill_panel_id: skill_panel_id,
        class: class,
        locked_date: locked_date
      ) do
    from(
      q in HistoricalSkillClass,
      where: q.skill_panel_id == ^skill_panel_id,
      where: q.class == ^class,
      where: q.locked_date == ^locked_date
    )
    |> Repo.one()
  end
end

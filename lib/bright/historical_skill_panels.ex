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

  TODO: 日付を暗黙的に3か月前にしているのを共通処理に移すこと。成長グラフ側と同様
  TODO: 現状では同じ日付に複数存在する可能性がある。別課題で対応後に修正
  """
  def get_historical_skill_class_on_date(skill_panel_id: skill_panel_id, class: class, date: date) do
    locked_date = Timex.shift(date, months: -3)

    from(
      q in HistoricalSkillClass,
      where: q.skill_panel_id == ^skill_panel_id,
      where: q.class == ^class,
      where: q.locked_date == ^locked_date,
      order_by: [desc: q.inserted_at],
      limit: 1
    )
    |> Repo.one()
  end
end

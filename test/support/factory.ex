defmodule Bright.Factory do
  @moduledoc """
  Factory using ex_machina.
  """

  use ExMachina.Ecto, repo: Bright.Repo

  # SkillPanels context
  use Bright.SkillPanelFactory
  use Bright.SkillClassFactory
  use Bright.SkillUnitFactory
end

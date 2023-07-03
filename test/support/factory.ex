defmodule Bright.Factory do
  @moduledoc """
  Factory using ex_machina.
  """

  use ExMachina.Ecto, repo: Bright.Repo

  # Accounts context
  use Bright.UserFactory
  use Bright.UserTokenFactory

  # SkillPanels context
  use Bright.SkillPanelFactory
  use Bright.SkillClassFactory
  use Bright.SkillUnitFactory
  use Bright.SkillCategoryFactory
  use Bright.SkillFactory
end

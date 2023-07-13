defmodule Bright.Factory do
  @moduledoc """
  Factory using ex_machina.
  """

  use ExMachina.Ecto, repo: Bright.Repo

  # Accounts context
  use Bright.UserFactory
  use Bright.UserTokenFactory

  # UserProfiles context
  use Bright.UserProfileFactory

  # SkillPanels context
  use Bright.SkillPanelFactory
  use Bright.SkillClassFactory

  # SkillUnits context
  use Bright.SkillUnitFactory
  use Bright.SkillCategoryFactory
  use Bright.SkillFactory

  # SkillScores context
  use Bright.SkillScoreFactory
  use Bright.SkillScoreItemFactory

  # SkillReferences context
  use Bright.SkillReferenceFactory

  # SkillExams context
  use Bright.SkillExamFactory
  use Bright.SkillExamResultFactory

  # SkillEvidences context
  use Bright.SkillEvidenceFactory

  # NotificationsFactory context
  use Bright.NotificationFactory
end

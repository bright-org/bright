defmodule Bright.Factory do
  @moduledoc """
  Factory using ex_machina.
  """

  use ExMachina.Ecto, repo: Bright.Repo

  # Accounts context
  use Bright.UserFactory
  use Bright.UserTokenFactory
  use Bright.User2faCodeFactory

  # UserProfiles context
  use Bright.UserProfileFactory

  # Onboardings context
  use Bright.UserOnboardingFactory

  # UserJobProfiles context
  use Bright.UserJobProfileFactory

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
  use Bright.SkillEvidencePostFactory

  # NotificationsFactory context
  use Bright.NotificationFactory
end

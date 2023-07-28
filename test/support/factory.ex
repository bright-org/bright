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

  # DraftSkillPanels context
  use Bright.DraftSkillPanelFactory
  use Bright.DraftSkillClassFactory

  # DraftSkillUnits context
  use Bright.DraftSkillUnitFactory
  use Bright.DraftSkillCategoryFactory
  use Bright.DraftSkillFactory

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

  # HistoricalSkillPanels context
  use Bright.HistoricalSkillPanelFactory
  use Bright.HistoricalSkillClassFactory

  # NotificationsFactory context
  use Bright.NotificationFactory
end

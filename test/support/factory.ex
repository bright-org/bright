defmodule Bright.Factory do
  @moduledoc """
  Factory using ex_machina.
  """

  use ExMachina.Ecto, repo: Bright.Repo

  # Accounts context
  use Bright.UserFactory
  use Bright.UserTokenFactory
  use Bright.User2faCodeFactory
  use Bright.UserSocialAuthFactory
  use Bright.UserSubEmailFactory
  use Bright.SocialIdentifierTokenFactory

  # UserProfiles context
  use Bright.UserProfileFactory

  # UserSkillPanels context
  use Bright.UserSkillPanelFactory

  # Onboardings context
  use Bright.UserOnboardingFactory

  # Jobs context
  use Bright.CareerWantFactory
  use Bright.CareerWantJobFactory
  use Bright.JobFactory
  use Bright.JobSkillPanelFactory

  # CareerFields context
  use Bright.CareerFieldFactory
  use Bright.CareerFieldJobFactory

  # UserJobProfiles context
  use Bright.UserJobProfileFactory

  # DraftSkillPanels context
  use Bright.DraftSkillPanelFactory
  use Bright.DraftSkillClassFactory

  # DraftSkillUnits context
  use Bright.DraftSkillUnitFactory
  use Bright.DraftSkillCategoryFactory
  use Bright.DraftSkillFactory
  use Bright.DraftSkillClassUnitFactory

  # SkillPanels context
  use Bright.SkillPanelFactory
  use Bright.SkillClassFactory

  # SkillUnits context
  use Bright.SkillUnitFactory
  use Bright.SkillCategoryFactory
  use Bright.SkillFactory
  use Bright.SkillClassUnitFactory

  # SkillScores context
  use Bright.SkillClassScoreFactory
  use Bright.SkillScoreFactory
  use Bright.SkillUnitScoreFactory
  use Bright.CareerFieldScoreFactory

  # SkillReferences context
  use Bright.SkillReferenceFactory

  # SkillExams context
  use Bright.SkillExamFactory

  # SkillEvidences context
  use Bright.SkillEvidenceFactory
  use Bright.SkillEvidencePostFactory

  # HistoricalSkillPanels context
  use Bright.HistoricalSkillPanelFactory
  use Bright.HistoricalSkillClassFactory

  # HistoricalSkillUnits context
  use Bright.HistoricalSkillUnitFactory
  use Bright.HistoricalSkillCategoryFactory
  use Bright.HistoricalSkillFactory
  use Bright.HistoricalSkillClassUnitFactory

  # HistoricalSkillScores context
  use Bright.HistoricalSkillScoreFactory
  use Bright.HistoricalSkillClassScoreFactory
  use Bright.HistoricalSkillUnitScoreFactory

  # Teams context
  use Bright.TeamFactory
  use Bright.TeamMemberUsersFactory
  use Bright.TeamSupporterTeamFactory

  # NotificationsFactory context
  use Bright.NotificationOperationFactory
  use Bright.NotificationCommunityFactory
  use Bright.NotificationEvidenceFactory
  use Bright.UserNotificationFactory

  # Bright.RecruitmentStockUserFactory
  use Bright.RecruitmentStockUserFactory

  # Subscription context
  use Bright.SubscriptionPlanFactory
  use Bright.SubscriptionPlanServiceFactory
  use Bright.SubscriptionUserPlanFactory

  # CustomGroups context
  use Bright.CustomGroupFactory
  use Bright.CustomGroupMemberUserFactory

  # Recruit context
  use Bright.InterviewFactory
  use Bright.InterviewMemberFactory

  # Chat context
  use Bright.ChatFactory
  use Bright.ChatMessageFactory
end

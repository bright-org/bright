defmodule Bright.Accounts.User do
  @moduledoc """
  Bright ユーザーを扱うスキーマ
  """

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Bright.Repo
  alias Bright.Accounts.UserSubEmail
  alias Bright.Accounts.User
  alias Bright.UserProfiles.UserProfile

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "users" do
    field :name, :string
    field :email, :string
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :password_registered, :boolean
    field :confirmed_at, :naive_datetime
    # 検索用 ソートカラム
    field :last_updated, :naive_datetime, virtual: true
    field :desired_income, :integer, virtual: true
    field :skill_score, :float, virtual: true

    has_many :users_tokens, Bright.Accounts.UserToken
    has_one :user_2fa_code, Bright.Accounts.User2faCodes
    has_many :user_social_auths, Bright.Accounts.UserSocialAuth
    has_many :user_sub_emails, Bright.Accounts.UserSubEmail

    has_many :skill_scores, Bright.SkillScores.SkillScore
    has_many :skill_class_scores, Bright.SkillScores.SkillClassScore
    has_many :skill_unit_scores, Bright.SkillScores.SkillUnitScore
    has_many :career_field_scores, Bright.SkillScores.CareerFieldScore
    has_many :skill_evidences, Bright.SkillEvidences.SkillEvidence
    has_many :skill_evidence_posts, Bright.SkillEvidences.SkillEvidencePost

    has_many :historical_skill_scores, Bright.HistoricalSkillScores.HistoricalSkillScore

    has_many :historical_skill_class_scores,
             Bright.HistoricalSkillScores.HistoricalSkillClassScore

    has_many :historical_skill_unit_scores, Bright.HistoricalSkillScores.HistoricalSkillUnitScore

    has_many :historical_career_field_scores,
             Bright.HistoricalSkillScores.HistoricalCareerFieldScore

    has_many :user_skill_panels, Bright.UserSkillPanels.UserSkillPanel

    has_many :skill_panels, through: [:user_skill_panels, :skill_panel]

    has_many :team_member_users, Bright.Teams.TeamMemberUsers

    has_many :teams, through: [:team_member_users, :team]

    has_many :custom_groups, Bright.CustomGroups.CustomGroup

    has_one :user_onboardings, Bright.Onboardings.UserOnboarding
    has_one :user_profile, Bright.UserProfiles.UserProfile
    has_one :user_job_profile, Bright.UserJobProfiles.UserJobProfile

    has_many :subscription_user_plans, Bright.Subscriptions.SubscriptionUserPlan

    has_one :user_notification, Bright.Notifications.UserNotification

    timestamps()
  end

  @doc """
  A user changeset for registration.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.

  ## Options

    * `:validate_name` - Validates the uniqueness of the name, in case
      you don't want to validate the uniqueness of the name (like when
      using this changeset for validations on a LiveView form before
      submitting the form), this option can be set to `false`.
      Defaults to `true`.

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.

    * `:validate_email` - Validates the uniqueness of the email and sub_email, in case
      you don't want to validate the uniqueness of the email (like when
      using this changeset for validations on a LiveView form before
      submitting the form), this option can be set to `false`.
      Defaults to `true`.
  """
  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:name, :email, :password])
    |> validate_name(opts)
    |> validate_email(opts)
    |> maybe_validate_uniqueness_in_user_sub_email(opts)
    |> validate_password(opts)
  end

  defp validate_name(changeset, opts) do
    changeset
    |> validate_required([:name])
    |> validate_length(:name, max: 30)
    |> maybe_validate_unique_name(opts)
  end

  @doc """
  Validates user email.

  ## Options

    * `:validate_email` - Validates the uniqueness of the email, in case
      you don't want to validate the uniqueness of the email (like when
      using this changeset for validations on a LiveView form before
      submitting the form), this option can be set to `false`.
      Defaults to `true`.
  """
  def validate_email(changeset, opts) do
    changeset
    |> validate_required([:email])
    |> validate_format(
      :email,
      ~r/^(?>[-[:alpha:][:alnum:]+_!"'#$%^&*{}\/=?`|~](?:\.?[-[:alpha:][:alnum:]+_!"'#$%^&*{}\/=?`|~]){0,63})@(?=.{1,255}$)(?:(?=[^.]{1,63}(?:\.|$))(?!.*?--.*$)[[:alnum:]](?:(?:[[:alnum:]]|-){0,61}[[:alnum:]])?\.)*(?=[^.]{1,63}(?:\.|$))(?!.*?--.*$)[[:alnum:]](?:(?:[[:alnum:]]|-){0,61}[[:alnum:]])?\.[[:alpha:]]{1,64}$/i
    )
    |> validate_length(:email, max: 160)
    |> maybe_validate_unique_email(opts)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 8, max: 72)
    |> validate_format(:password, ~r/[a-zA-Z]/,
      message: "at least one upper or lower case character"
    )
    |> validate_format(:password, ~r/[0-9]/, message: "at least one digit")
    |> maybe_hash_password(opts)
  end

  defp maybe_validate_unique_name(changeset, opts) do
    if Keyword.get(opts, :validate_name, true) do
      changeset
      |> unsafe_validate_unique(:name, Bright.Repo)
      |> unique_constraint(:name)
    else
      changeset
    end
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      # If using Bcrypt, then further validate it is at most 72 bytes long
      |> validate_length(:password, max: 72, count: :bytes)
      # Hashing could be done with `Ecto.Changeset.prepare_changes/2`, but that
      # would keep the database transaction open longer and hurt performance.
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  defp maybe_validate_unique_email(changeset, opts) do
    if Keyword.get(opts, :validate_email, true) do
      changeset
      |> unsafe_validate_unique(:email, Bright.Repo)
      |> unique_constraint(:email)
    else
      changeset
    end
  end

  defp maybe_validate_uniqueness_in_user_sub_email(changeset, opts) do
    if Keyword.get(opts, :validate_email, true) do
      validate_uniqueness_in_user_sub_email(changeset)
    else
      changeset
    end
  end

  defp validate_uniqueness_in_user_sub_email(changeset) do
    validate_change(changeset, :email, fn :email, email ->
      if UserSubEmail.email_query(email) |> Repo.exists?() do
        [email: "has already been taken"]
      else
        []
      end
    end)
  end

  @doc """
  A user changeset for registration by social auth (OAuth).
  """
  def registration_by_social_auth_changeset(user, attrs, opts \\ []) do
    user
    |> cast_user_when_social_auth(attrs, opts)
    |> validate_password_registered(opts)
    |> validate_name(opts)
    |> validate_email(opts)
    |> maybe_validate_uniqueness_in_user_sub_email(opts)
    |> maybe_hash_password(opts)
  end

  defp cast_user_when_social_auth(user, attrs, opts) do
    if Keyword.get(opts, :generate_dummy_password, true) do
      attrs = merge_dummy_password(attrs)

      user
      |> cast(attrs, [:name, :email, :password, :password_registered])
    else
      user
      |> cast(attrs, [:name, :email])
    end
  end

  # NOTE: user テーブルの hashed_password カラムは NULL 不許可なので SNS ID 登録の際はダミーの値を生成
  # 同時に password_registered を false にして無効なパスワード扱いとする
  defp merge_dummy_password(attrs) do
    attrs
    |> Map.merge(%{
      "password" => generate_dummy_password(),
      "password_registered" => false
    })
  end

  # ランダムな数字8文字 + 英字8文字
  defp generate_dummy_password() do
    for(
      _ <- 1..8,
      into: "",
      do: Enum.random(0..9) |> to_string()
    ) <>
      for(
        _ <- 1..8,
        into: "",
        do: <<Enum.random(?a..?z)>>
      )
  end

  defp validate_password_registered(changeset, opts) do
    if Keyword.get(opts, :validate_password_registered, true) do
      changeset
      |> validate_required([:password_registered])
      |> validate_inclusion(:password_registered, [false])
    else
      changeset
    end
  end

  @doc """
  A user changeset for changing user name and user_profile
  """
  def user_with_profile_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:name])
    |> validate_name(opts)
    |> cast_assoc(:user_profile, with: &UserProfile.changeset_for_user_setting/2)
  end

  @doc """
  A user changeset for changing the email.

  It requires the email to change otherwise an error is added.
  """
  def email_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email])
    |> validate_email(opts)
    |> maybe_validate_uniqueness_in_user_sub_email(opts)
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end

  @doc """
  A user changeset for changing the password.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(user) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    change(user, confirmed_at: now)
  end

  @doc """
  Verifies the password.

  If there is no user or the user doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(
        %Bright.Accounts.User{hashed_password: hashed_password, password_registered: true},
        password
      )
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  def validate_current_password(changeset, password) do
    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "does not match current password")
    end
  end

  @doc """
  Select confirmed user by email.

  When `:including_not_confirmed` option is given and true, search user including not confirmed (default false).
  """
  def email_query(email) do
    from(u in User,
      where:
        u.email == ^email and
          not is_nil(u.confirmed_at)
    )
  end

  def email_query(email, including_not_confirmed: true) do
    from(u in User,
      where: u.email == ^email
    )
  end

  @doc """
  Select confirmed users primary emails.
  """
  def confirmed_users_emails_query() do
    from(u in User,
      where: not is_nil(u.confirmed_at),
      select: u.email
    )
  end

  @doc """
  Select confirmed users sub emails.
  """
  def confirmed_users_sub_emails_query() do
    from(user in User,
      where: not is_nil(user.confirmed_at),
      join: user_sub_email in assoc(user, :user_sub_emails),
      select: user_sub_email.email
    )
  end
end

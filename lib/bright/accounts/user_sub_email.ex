defmodule Bright.Accounts.UserSubEmail do
  @moduledoc """
  Bright ユーザーのサブメールアドレスを扱うスキーマ
  """

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false
  alias Bright.Repo
  alias Bright.Accounts.User
  alias Bright.Accounts.UserSubEmail

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "user_sub_emails" do
    field :email, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def max_sub_email_num, do: 3

  @doc """
  A changeset for user sub_email.

  ## Options

    * `:validate_email` - Validates the uniqueness of the email, in case
      you don't want to validate the uniqueness of the email (like when
      using this changeset for validations on a LiveView form before
      submitting the form), this option can be set to `false`.
      Defaults to `true`.
    * `:validate_sub_email_count` - Validates that the count of user
      sub email is less than or equal to @max_sub_email_num (now it's 3).
      you don't want to validate the uniqueness of the email (like when
      using this changeset for validations on a LiveView form before
      submitting the form), this option can be set to `false`.
      Defaults to `true`.
  """
  def changeset(user_sub_email, attrs, opts \\ []) do
    user_sub_email
    |> cast(attrs, [:user_id, :email])
    |> validate_required([:user_id, :email])
    |> maybe_validate_user_email_count(opts)
    |> User.validate_email(opts)
    |> maybe_validate_uniqueness_in_user_email(opts)
  end

  defp maybe_validate_user_email_count(changeset, opts) do
    if Keyword.get(opts, :validate_sub_email_count, true) do
      validate_user_email_count(changeset)
    else
      changeset
    end
  end

  defp validate_user_email_count(changeset) do
    user_id = get_field(changeset, :user_id)

    if user_sub_email_count(user_id) >= max_sub_email_num() do
      add_error(changeset, :email, "already has max number of sub emails")
    else
      changeset
    end
  end

  defp user_sub_email_count(user_id) do
    from(u in UserSubEmail, where: u.user_id == ^user_id) |> Repo.aggregate(:count)
  end

  defp maybe_validate_uniqueness_in_user_email(changeset, opts) do
    if Keyword.get(opts, :validate_email, true) do
      validate_uniqueness_in_user_email(changeset)
    else
      changeset
    end
  end

  defp validate_uniqueness_in_user_email(changeset) do
    validate_change(changeset, :email, fn :email, email ->
      if User.email_query(email, including_not_confirmed: true) |> Repo.exists?() do
        [email: "has already been taken"]
      else
        []
      end
    end)
  end

  @doc """
  Get a user_sub_email by user and email
  """
  def user_and_email_query(user, email) do
    from(u in UserSubEmail, where: u.user_id == ^user.id and u.email == ^email)
  end

  @doc """
  Get a user_sub_email by email
  """
  def email_query(email) do
    from(u in UserSubEmail, where: u.email == ^email)
  end
end

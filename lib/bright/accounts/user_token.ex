defmodule Bright.Accounts.UserToken do
  @moduledoc """
  Bright ユーザーのトークン管理を扱うスキーマ
  """

  use Ecto.Schema
  import Ecto.Query
  alias Bright.Accounts.UserToken

  @hash_algorithm :sha256
  @rand_size 32

  @two_factor_auth_session_validity %{"ago" => 1, "intervals" => "hour"}
  @two_factor_auth_done_validity %{"ago" => 60, "intervals" => "day"}
  @reset_password_validity %{"ago" => 1, "intervals" => "day"}
  @confirm_validity %{"ago" => 30, "intervals" => "minute"}
  @change_email_validity %{"ago" => 1, "intervals" => "day"}
  @confirm_sub_email_validity %{"ago" => 1, "intervals" => "day"}
  @session_validity_in_days 60

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "users_tokens" do
    field(:token, :binary)
    field(:context, :string)
    field(:sent_to, :string)
    belongs_to(:user, Bright.Accounts.User)

    timestamps(updated_at: false)
  end

  @doc """
  Generates a token that will be stored in a signed place,
  such as session or cookie. As they are signed, those
  tokens do not need to be hashed.

  The reason why we store session tokens in the database, even
  though Phoenix already provides a session cookie, is because
  Phoenix' default session cookies are not persisted, they are
  simply signed and potentially encrypted. This means they are
  valid indefinitely, unless you change the signing/encryption
  salt.

  Therefore, storing them allows individual user
  sessions to be expired. The token system can also be extended
  to store additional data, such as the device used for logging in.
  You could then use this information to display all valid sessions
  and devices in the UI and allow users to explicitly expire any
  session they deem invalid.
  """
  def build_session_token(user) do
    token = :crypto.strong_rand_bytes(@rand_size)
    {token, %UserToken{token: token, context: "session", user_id: user.id}}
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the user found by the token, if any.

  The token is valid if it matches the value in the database and it has
  not expired (after @session_validity_in_days).
  """
  def verify_session_token_query(token) do
    query =
      from(token in token_and_context_query(token, "session"),
        join: user in assoc(token, :user),
        where: token.inserted_at > ago(@session_validity_in_days, "day"),
        select: user
      )

    {:ok, query}
  end

  @doc """
  Builds a token and its hash to be delivered to the user's email.

  The non-hashed token is sent to the user email while the
  hashed part is stored in the database. The original token cannot be reconstructed,
  which means anyone with read-only access to the database cannot directly use
  the token in the application to gain access. Furthermore, if the user changes
  their email in the system, the tokens sent to the previous email are no longer
  valid.

  Users can easily adapt the existing code to provide other types of delivery methods,
  for example, by phone numbers.
  """
  def build_email_token(user, context) do
    build_hashed_token(user, context, user.email)
  end

  def build_email_token(user, context, sent_to) do
    build_hashed_token(user, context, sent_to)
  end

  @doc """
  Builds a token which is not related to specific email.
  """
  def build_user_token(user, context) do
    build_hashed_token(user, context, nil)
  end

  defp build_hashed_token(user, context, sent_to) do
    token = :crypto.strong_rand_bytes(@rand_size)
    hashed_token = :crypto.hash(@hash_algorithm, token)

    {Base.url_encode64(token, padding: false),
     %UserToken{
       token: hashed_token,
       context: context,
       sent_to: sent_to,
       user_id: user.id
     }}
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the user found by the token, if any.

  The given token is valid if it matches its hashed counterpart in the
  database and the user email has not changed. This function also checks
  if the token is being used within a certain period, depending on the
  context. The default contexts supported by this function are either
  "confirm", for account confirmation emails, and "reset_password",
  for resetting the password. For verifying requests to change the email,
  see `verify_change_email_token_query/2`.
  """
  def verify_email_token_query(token, context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)

        query =
          from(token in token_and_context_query(hashed_token, context),
            join: user in assoc(token, :user),
            where:
              token.inserted_at >
                ago(
                  ^validity_ago(context),
                  ^validity_intervals(context)
                ) and token.sent_to == user.email,
            select: user
          )

        {:ok, query}

      :error ->
        :error
    end
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the user found by the token, if any.

  This is used to validate requests to change the user
  email. It is different from `verify_email_token_query/2` precisely because
  `verify_email_token_query/2` validates the email has not changed, which is
  the starting point by this function.

  The given token is valid if it matches its hashed counterpart in the
  database and if it has not expired (after @change_email_validity).
  The context must always start with "change:".
  """
  def verify_change_email_token_query(token, "change:" <> _ = context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)

        query =
          from(token in token_and_context_query(hashed_token, context),
            where:
              token.inserted_at >
                ago(^@change_email_validity["ago"], ^@change_email_validity["intervals"])
          )

        {:ok, query}

      :error ->
        :error
    end
  end

  @doc """
  Checks if the two factor auth token is valid and returns its underlying lookup query.
  """
  def verify_two_factor_auth_token_query(token, context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)

        query =
          from(token in token_and_context_query(hashed_token, context),
            join: user in assoc(token, :user),
            where:
              token.inserted_at >
                ago(
                  ^validity_ago(context),
                  ^validity_intervals(context)
                ),
            select: user
          )

        {:ok, query}

      :error ->
        :error
    end
  end

  @doc """
  Checks if the confirm sub email token is valid and returns its underlying lookup query.
  """
  def verify_confirm_sub_email_token_query(token, context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)

        query =
          from(token in token_and_context_query(hashed_token, context),
            where:
              token.inserted_at >
                ago(
                  ^@confirm_sub_email_validity["ago"],
                  ^@confirm_sub_email_validity["intervals"]
                )
          )

        {:ok, query}

      :error ->
        :error
    end
  end

  defp validity_ago("two_factor_auth_session"),
    do: @two_factor_auth_session_validity["ago"]

  defp validity_ago("two_factor_auth_done"),
    do: @two_factor_auth_done_validity["ago"]

  defp validity_ago("reset_password"),
    do: @reset_password_validity["ago"]

  defp validity_ago("confirm"),
    do: @confirm_validity["ago"]

  defp validity_intervals("two_factor_auth_session"),
    do: @two_factor_auth_session_validity["intervals"]

  defp validity_intervals("two_factor_auth_done"),
    do: @two_factor_auth_done_validity["intervals"]

  defp validity_intervals("reset_password"),
    do: @reset_password_validity["intervals"]

  defp validity_intervals("confirm"),
    do: @confirm_validity["intervals"]

  @doc """
  Returns the token struct for the given token value and context.
  """
  def token_and_context_query(token, context) do
    from(UserToken, where: [token: ^token, context: ^context])
  end

  @doc """
  Gets all tokens for the given user for the given contexts.
  """
  def user_and_contexts_query(user, :all) do
    from(t in UserToken, where: t.user_id == ^user.id)
  end

  def user_and_contexts_query(user, [_ | _] = contexts) do
    from(t in UserToken, where: t.user_id == ^user.id and t.context in ^contexts)
  end
end

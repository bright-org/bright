defmodule Bright.Chats do
  @moduledoc """
  The Chats context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo
  alias Bright.Accounts.{UserNotifier, User}
  alias Bright.UserProfiles.UserProfile
  alias Bright.Chats.Chat
  alias Bright.Chats.ChatUser
  alias Bright.Chats.ChatMessage
  alias Bright.Recruits.Interview

  @doc """
  Returns the list of chats.

  ## Examples

      iex> list_chats()
      [%Chat{}, ...]

  """
  def list_chats do
    Repo.all(Chat)
  end

  def list_chats(user_id, :recruit) do
    from(
      c in Chat,
      join: m in ChatUser,
      on: m.user_id == ^user_id and m.chat_id == c.id,
      join: i in Interview,
      on: i.id == c.relation_id and i.status in [:consume_interview, :ongoing_interview],
      join: p in UserProfile,
      on: p.user_id == i.candidates_user_id,
      where: c.relation_type == "recruit",
      order_by: [desc: :updated_at],
      select: %{c | interview: %{i | candidates_user_icon: p.icon_file_path}}
    )
    |> Repo.all()
  end

  @doc """
  Gets a single chat.

  Raises `Ecto.NoResultsError` if the Chat does not exist.

  ## Examples

      iex> get_chat!(123)
      %Chat{}

      iex> get_chat!(456)
      ** (Ecto.NoResultsError)

  """
  def get_chat!(id), do: Repo.get!(Chat, id)

  def get_chat_with_messages_and_interview!(id, user_id) do
    from(c in Chat,
      where: c.id == ^id and c.relation_type == "recruit",
      join: m in ChatUser,
      on: m.user_id == ^user_id and m.chat_id == c.id,
      preload: [:messages, :users],
      join: i in Interview,
      on: i.id == c.relation_id and i.status in [:consume_interview, :ongoing_interview],
      join: u in User,
      on: u.id == i.candidates_user_id,
      join: p in UserProfile,
      on: p.user_id == i.candidates_user_id,
      select: %{
        c
        | interview: %{i | candidates_user_name: u.name, candidates_user_icon: p.icon_file_path}
      }
    )
    |> Repo.one!()
  end

  def get_or_create_chat(owner_user_id, relation_id, relation_type, chat_users \\ []) do
    query =
      from(
        c in Chat,
        where:
          c.owner_user_id == ^owner_user_id and
            c.relation_type == ^relation_type and
            c.relation_id == ^relation_id
      )

    case Repo.exists?(query) do
      true ->
        query
        |> preload(:messages)
        |> Repo.one()

      false ->
        {:ok, chat} =
          create_chat(%{
            owner_user_id: owner_user_id,
            relation_type: relation_type,
            relation_id: relation_id,
            chat_users: chat_users
          })

        Map.put(chat, :messages, [])
    end
  end

  @doc """
  Creates a chat.

  ## Examples

      iex> create_chat(%{field: value})
      {:ok, %Chat{}}

      iex> create_chat(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_chat(attrs \\ %{}) do
    %Chat{}
    |> Chat.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a chat.

  ## Examples

      iex> update_chat(chat, %{field: new_value})
      {:ok, %Chat{}}

      iex> update_chat(chat, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_chat(%Chat{} = chat, attrs) do
    chat
    |> Chat.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a chat.

  ## Examples

      iex> delete_chat(chat)
      {:ok, %Chat{}}

      iex> delete_chat(chat)
      {:error, %Ecto.Changeset{}}

  """
  def delete_chat(%Chat{} = chat) do
    Repo.delete(chat)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking chat changes.

  ## Examples

      iex> change_chat(chat)
      %Ecto.Changeset{data: %Chat{}}

  """
  def change_chat(%Chat{} = chat, attrs \\ %{}) do
    Chat.changeset(chat, attrs)
  end

  def change_message(%ChatMessage{} = message, attrs \\ %{}) do
    ChatMessage.changeset(message, attrs)
  end

  def create_message(attrs \\ %{}) do
    %ChatMessage{}
    |> ChatMessage.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:send_message)
  end

  def broadcast({:ok, message}, :send_message) do
    Phoenix.PubSub.broadcast(
      Bright.PubSub,
      "chat:#{message.chat_id}",
      {:send_message, message}
    )

    {:ok, message}
  end

  def deliver_new_message_notification_email_instructions(
        to_user,
        chat,
        chat_url_fun
      )
      when is_function(chat_url_fun, 1) do
    if !Bright.Utils.Env.prod?() or Application.get_env(:bright, :dev_routes) do
      :ets.insert(
        :token,
        {"new_message", to_user.email, to_user.name, chat_url_fun.(chat.id)}
      )
    end

    UserNotifier.deliver_new_message_notification_instructions(
      to_user,
      chat_url_fun.(chat.id)
    )
  end
end

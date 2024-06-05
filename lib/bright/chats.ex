defmodule Bright.Chats do
  @moduledoc """
  The Chats context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo
  alias Bright.Accounts.{UserNotifier, User}
  alias Bright.UserProfiles.UserProfile
  alias Bright.Chats
  alias Bright.Chats.Chat
  alias Bright.Chats.ChatUser
  alias Bright.Chats.ChatMessage
  alias Bright.Recruits.Interview
  alias Bright.Utils.GoogleCloud.Storage

  @interview_status_all [
    :waiting_decision,
    :consume_interview,
    :dismiss_interview,
    :ongoing_interview,
    :completed_interview,
    :cancel_interview,
    :one_on_one
  ]

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
    list_chats(user_id, @interview_status_all)
  end

  def list_chats(user_id, :not_completed_interview) do
    status =
      @interview_status_all
      |> Enum.reject(fn key -> key == :completed_interview end)

    list_chats(user_id, status)
  end

  def list_chats(user_id, status) when is_atom(status), do: list_chats(user_id, [status])

  def list_chats(user_id, status) when is_list(status) do
    from(
      c in Chat,
      join: m in ChatUser,
      on: m.user_id == ^user_id and m.chat_id == c.id,
      join: i in Interview,
      on: i.id == c.relation_id,
      where: c.relation_type == "recruit",
      order_by: [desc: :updated_at],
      join: cu in User,
      on: cu.id == i.candidates_user_id,
      join: cp in UserProfile,
      on: cp.user_id == i.candidates_user_id,
      join: ru in User,
      on: ru.id == i.recruiter_user_id,
      join: rp in UserProfile,
      on: rp.user_id == i.recruiter_user_id,
      where: i.status in ^status,
      select: %{
        c
        | interview: %{
            i
            | candidates_user_name: cu.name,
              candidates_user_icon: cp.icon_file_path,
              recruiter_user_name: ru.name,
              recruiter_user_icon: rp.icon_file_path,
              is_read?: m.is_read
          }
      }
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
      preload: [:users, messages: :files],
      join: i in Interview,
      on: i.id == c.relation_id,
      join: cu in User,
      on: cu.id == i.candidates_user_id,
      join: cp in UserProfile,
      on: cp.user_id == i.candidates_user_id,
      join: ru in User,
      on: ru.id == i.recruiter_user_id,
      join: rp in UserProfile,
      on: rp.user_id == i.recruiter_user_id,
      select: %{
        c
        | interview: %{
            i
            | candidates_user_name: cu.name,
              candidates_user_icon: cp.icon_file_path,
              recruiter_user_name: ru.name,
              recruiter_user_icon: rp.icon_file_path,
              is_read?: m.is_read
          }
      }
    )
    |> Repo.one!()
  end

  def get_or_create_chat(owner_user_id, relation_id, relation_type, chat_users) do
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

  def get_or_create_chat(
        recruiter_user_id,
        candidates_user_id,
        relation_id,
        relation_type,
        chat_users
      ) do
    query =
      from(
        c in Chat,
        where:
          (c.owner_user_id == ^recruiter_user_id and
             c.relation_type == ^relation_type and
             c.relation_id == ^relation_id) or
            (c.owner_user_id == ^candidates_user_id and
               c.relation_type == ^relation_type and
               c.relation_id == ^relation_id)
      )

    case Repo.exists?(query) do
      true ->
        query
        |> preload(:messages)
        |> Repo.one()

      false ->
        {:ok, chat} =
          create_chat(%{
            owner_user_id: recruiter_user_id,
            relation_type: relation_type,
            relation_id: relation_id,
            chat_users: chat_users
          })

        Map.put(chat, :messages, [])
    end
  end

  def get_chat_by_interview_id(interview_id) do
    Chat
    |> where([c], c.relation_type == "recruit" and c.relation_id == ^interview_id)
    |> Repo.one()
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

  @doc """
  Creates a chat_message and updates chat_users except sender_user is_read to false.

  ## Examples
      iex> create_message(%{field: value}, nil)
      {:ok, %ChatMessage{}}

      iex> create_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def create_message(attrs, nil) do
    Ecto.Multi.new()
    |> insert_chat_message_multi(attrs)
    |> update_chat_users_unread_multi()
    |> Repo.transaction()
    |> case do
      {:ok, %{message: message}} -> broadcast({:ok, message}, :send_message)
      {:error, :message, changeset, _} -> {:error, changeset}
    end
  end

  def create_message(attrs, socket) do
    Ecto.Multi.new()
    |> insert_chat_message_multi(attrs)
    |> update_chat_users_unread_multi()
    |> Ecto.Multi.run(:upload_gcs_images, fn _repo, %{message: _message} ->
      Phoenix.LiveView.consume_uploaded_entries(socket, :images, fn %{path: path}, entry ->
        file_path = Chats.ChatFile.build_file_path(:images, entry.client_name, entry.uuid)
        :ok = Storage.upload!(path, file_path)
        {:ok, :uploaded}
      end)

      {:ok, :uploaded}
    end)
    |> Ecto.Multi.run(:upload_gcs_files, fn _repo, %{message: _message} ->
      Phoenix.LiveView.consume_uploaded_entries(socket, :files, fn %{path: path}, entry ->
        file_path = Chats.ChatFile.build_file_path(:files, entry.client_name, entry.uuid)
        :ok = Storage.upload!(path, file_path)
        {:ok, :uploaded}
      end)

      {:ok, :uploaded}
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{message: message}} -> broadcast({:ok, message}, :send_message)
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  defp insert_chat_message_multi(multi, attrs) do
    Ecto.Multi.insert(multi, :message, ChatMessage.changeset(%ChatMessage{}, attrs))
  end

  defp update_chat_users_unread_multi(multi) do
    Ecto.Multi.update_all(
      multi,
      :update_chat_users_unread,
      fn %{message: %{chat_id: chat_id, sender_user_id: sender_user_id}} ->
        ChatUser.chat_users_except_sender_query(chat_id, sender_user_id)
      end,
      set: [is_read: false]
    )
  end

  @doc """
  Updates chat user is_read to true.

  ## Examples

      iex> read_chat!(chat_id, user_id)
      :ok
  """
  def read_chat!(chat_id, user_id) do
    ChatUser.chat_user_query(chat_id, user_id)
    |> Repo.update_all(set: [is_read: true])

    :ok
  end

  @doc """
  Build file_path by file_name.

  ## Examples

      iex> build_file_path("uploaded_file.png")
      "/chats/message_file_xxxxx.png"
  """
  def build_file_path(file_name) do
    "chats/message_file_#{Ecto.UUID.generate()}" <> Path.extname(file_name)
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

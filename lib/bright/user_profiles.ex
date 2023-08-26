defmodule Bright.UserProfiles do
  @moduledoc """
  The UserProfiles context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.UserProfiles.UserProfile
  alias Bright.Accounts.User
  alias Bright.UserProfiles.UserProfile
  alias Bright.Utils.GoogleCloud.Storage

  @doc """
  Returns the list of user_profiles.

  ## Examples

      iex> list_user_profiles()
      [%UserProfile{}, ...]

  """
  def list_user_profiles do
    Repo.all(UserProfile)
    |> Repo.preload(:user)
  end

  @doc """
  Gets a single user_profile.

  Raises `Ecto.NoResultsError` if the User profile does not exist.

  ## Examples

      iex> get_user_profile!(123)
      %UserProfile{}

      iex> get_user_profile!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_profile!(id), do: Repo.get!(UserProfile, id) |> Repo.preload(:user)

  @doc """
  Creates a user_profile.

  ## Examples

      iex> create_user_profile(%{field: value})
      {:ok, %UserProfile{}}

      iex> create_user_profile(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_profile(attrs \\ %{}) do
    %UserProfile{}
    |> UserProfile.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a initial user_profile.

  ## Examples

      iex> create_initial_user_profile(user_id)
      {:ok, %UserProfile{}}

  """
  def create_initial_user_profile(user_id) do
    create_user_profile(%{user_id: user_id})
  end

  @doc """
  Gets a single user_profile.

  ## Examples

      iex> get_user_profile_by_name("name")
      %UserProfile{}

  """
  def get_user_profile_by_name(name) do
    user_name_query(name)
    |> Repo.one()
    |> Repo.preload(:user)
  end

  defp user_name_query(name) do
    from p in UserProfile,
      inner_join: u in User,
      on: p.user_id == u.id,
      where: u.name == ^name
  end

  @doc """
  Updates a user_profile.

  ## Examples

      iex> update_user_profile(user_profile, %{field: new_value})
      {:ok, %UserProfile{}}

      iex> update_user_profile(user_profile, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_profile(%UserProfile{} = user_profile, attrs) do
    user_profile
    |> UserProfile.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_profile.

  ## Examples

      iex> delete_user_profile(user_profile)
      {:ok, %UserProfile{}}

      iex> delete_user_profile(user_profile)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_profile(%UserProfile{} = user_profile) do
    Repo.delete(user_profile)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_profile changes.

  ## Examples

      iex> change_user_profile(user_profile)
      %Ecto.Changeset{data: %UserProfile{}}

  """
  def change_user_profile(%UserProfile{} = user_profile, attrs \\ %{}) do
    UserProfile.changeset(user_profile, attrs)
  end

  @doc """
  Return url for user_profile icon.

  ## Examples

      iex> icon_url(nil)
      "/images/avatar.png"

      iex> icon_url(icon_file_path)
      "https://storage.googleapis.com/bucket_name/xxx.png"
  """
  def icon_url(nil) do
    "/images/avatar.png"
  end

  def icon_url(icon_file_path) do
    Storage.public_url(icon_file_path)
  end

  @doc """
  Build icon_file_path by file_name.

  ## Examples

      iex> build_icon_path("uploaded_file.png")
      "/users/profile_icon_xxxxx.png"
  """
  def build_icon_path(file_name) do
    "users/profile_icon_#{Ecto.UUID.generate()}" <> Path.extname(file_name)
  end
end

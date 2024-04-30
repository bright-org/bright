defmodule Bright.ResourceOwners do
  @moduledoc false
  @behaviour Boruta.Oauth.ResourceOwners

  alias Boruta.Oauth.ResourceOwner
  alias Bright.Accounts.User
  alias Bright.Repo

  @impl Boruta.Oauth.ResourceOwners
  def get_by(username: username) do
    # NOTE: credo の Readability 警告が出るが自動生成によるコードかつ大きな問題ではないので無視する
    # credo:disable-for-next-line
    with %User{id: id, email: email} <- Repo.get_by(User, email: username) do
      {:ok, %ResourceOwner{sub: to_string(id), username: email}}
    else
      _ -> {:error, "User not found."}
    end
  end

  def get_by(sub: sub) do
    # NOTE: credo の Readability 警告が出るが自動生成によるコードかつ大きな問題ではないので無視する
    # credo:disable-for-next-line
    with %User{id: id, email: email} <- Repo.get_by(User, id: sub) do
      {:ok, %ResourceOwner{sub: to_string(id), username: email}}
    else
      _ -> {:error, "User not found."}
    end
  end

  @impl Boruta.Oauth.ResourceOwners
  def check_password(resource_owner, password) do
    user = Repo.get_by(User, id: resource_owner.sub)

    case User.valid_password?(user, password) do
      true -> :ok
      false -> {:error, "Invalid email or password."}
    end
  end

  @impl Boruta.Oauth.ResourceOwners
  def authorized_scopes(%ResourceOwner{}), do: []

  @impl Boruta.Oauth.ResourceOwners
  def claims(_resource_owner, _scope), do: %{}
end

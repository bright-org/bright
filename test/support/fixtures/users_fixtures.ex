defmodule Bright.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bright.Users` context.
  """

  @doc """
  Generate a bright_user.
  """
  def bright_user_fixture(attrs \\ %{}) do
    {:ok, bright_user} =
      attrs
      |> Enum.into(%{
        password: "some password",
        handle_name: "some handle_name",
        email: "some email"
      })
      |> Bright.Users.create_bright_user()

    bright_user
  end
end

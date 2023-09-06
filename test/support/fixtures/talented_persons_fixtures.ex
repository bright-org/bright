defmodule Bright.TalentedPersonsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bright.TalentedPersons` context.
  """

  @doc """
  Generate a talented_person.
  """
  def talented_person_fixture(attrs \\ %{}) do
    {:ok, talented_person} =
      attrs
      |> Enum.into(%{
        introducer_user_id: "7488a646-e31f-11e4-aace-600308960662",
        fave_user_id: "7488a646-e31f-11e4-aace-600308960662",
        team_id: "7488a646-e31f-11e4-aace-600308960662",
        fave_point: "some fave_point"
      })
      |> Bright.TalentedPersons.create_talented_person()

    talented_person
  end
end

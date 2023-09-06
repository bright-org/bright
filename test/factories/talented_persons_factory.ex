defmodule Bright.TalentedPersonFactory do
  @moduledoc """
  Factory for Bright.TalentedPersons.TalentedPerson
  """

  defmacro __using__(_opts) do
    quote do
      def talented_person_factory do
        %Bright.TalentedPersons.TalentedPerson{
          introducer_user: build(:user),
          fave_user: build(:user),
          team: build(:team),
          fave_point: Faker.Lorem.word()
        }
      end
    end
  end
end

defmodule Bright.Repo.Migrations.CreateOnboardingWants do
  use Ecto.Migration

  def change do
    create table(:onboarding_wants) do
      add :name, :string
      add :position, :integer

      timestamps()
    end
  end
end

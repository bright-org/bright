defmodule Bright.Repo.Migrations.CreateCareerWants do
  use Ecto.Migration

  def change do
    create table(:career_wants) do
      add :name, :string
      add :position, :integer

      timestamps()
    end
  end
end

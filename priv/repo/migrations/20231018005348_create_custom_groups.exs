defmodule Bright.Repo.Migrations.CreateCustomGroups do
  use Ecto.Migration

  def change do
    create table(:custom_groups) do
      add :name, :string
      add :user_id, references(:users, on_delete: :nothing), null: false

      timestamps()
    end

    create unique_index(:custom_groups, [:user_id, :name])
  end
end

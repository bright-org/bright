defmodule Bright.Repo.Migrations.CreateJobs do
  use Ecto.Migration

  def change do
    create table(:jobs) do
      add :name, :string
      add :position, :integer
      add :career_fied_id, references(:career_fields, on_delete: :nothing)

      timestamps()
    end

    create index(:jobs, [:career_fied_id])
  end
end

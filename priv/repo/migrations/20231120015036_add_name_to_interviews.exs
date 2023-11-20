defmodule Bright.Repo.Migrations.AddNameToInterviews do
  use Ecto.Migration

  def change do
    alter table(:interviews) do
      add :name, :string, default: "", null: false
    end
  end
end

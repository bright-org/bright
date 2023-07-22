defmodule Bright.Repo.Migrations.CreateCareerFields do
  use Ecto.Migration

  def change do
    create table(:career_fields) do
      add :name, :string
      add :background_color, :string
      add :button_color, :string
      add :position, :integer

      timestamps()
    end
  end
end

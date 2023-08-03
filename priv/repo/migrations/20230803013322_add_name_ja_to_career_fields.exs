defmodule Bright.Repo.Migrations.AddNameJaToCareerFields do
  use Ecto.Migration

  def change do
    alter table(:career_fields) do
      add :name_ja, :string, null: false
      remove :background_color, :string
      remove :button_color, :string
    end

    rename table("career_fields"), :name, to: :name_en
  end
end

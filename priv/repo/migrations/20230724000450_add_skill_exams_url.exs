defmodule Bright.Repo.Migrations.AddSkillExamsUrl do
  use Ecto.Migration

  def change do
    alter table(:skill_exams) do
      add :url, :string
    end
  end
end

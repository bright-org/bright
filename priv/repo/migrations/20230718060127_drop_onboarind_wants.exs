defmodule Bright.Repo.Migrations.DropOnboarindWants do
  use Ecto.Migration

  def up do
    drop table("onboarding_wants")
  end

  def down do
    create table(:onboarding_wants) do
      add :name, :string
      add :position, :integer

      timestamps()
    end
  end
end

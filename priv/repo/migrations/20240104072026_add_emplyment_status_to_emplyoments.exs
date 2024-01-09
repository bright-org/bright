defmodule Bright.Repo.Migrations.AddEmplymentStatusToEmplyoments do
  use Ecto.Migration

  def change do
    alter table(:employments) do
      add :employment_status, :string
    end
  end
end

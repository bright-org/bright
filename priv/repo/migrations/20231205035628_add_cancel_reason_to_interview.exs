defmodule Bright.Repo.Migrations.AddCancelReasonToInterview do
  use Ecto.Migration

  def change do
    alter table(:interviews) do
      add :cancel_reason, :string
    end
  end
end

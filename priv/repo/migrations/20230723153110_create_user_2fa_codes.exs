defmodule Bright.Repo.Migrations.CreateUser2faCodes do
  use Ecto.Migration

  def change do
    create table(:user_2fa_codes) do
      add :code, :string, null: false
      add :sent_to, :string, null: false
      add :user_id, references(:users, on_delete: :nothing), null: false

      timestamps(updated_at: false)
    end

    create unique_index(:user_2fa_codes, [:user_id, :code])
    create unique_index(:user_2fa_codes, [:sent_to])
  end
end

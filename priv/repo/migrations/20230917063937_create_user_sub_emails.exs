defmodule Bright.Repo.Migrations.CreateUserSubEmails do
  use Ecto.Migration

  def change do
    create table(:user_sub_emails) do
      add :email, :citext, null: false
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:user_sub_emails, [:user_id])
    create unique_index(:user_sub_emails, [:email])
  end
end

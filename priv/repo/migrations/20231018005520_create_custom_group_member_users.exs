defmodule Bright.Repo.Migrations.CreateCustomGroupMemberUsers do
  use Ecto.Migration

  def change do
    create table(:custom_group_member_users) do
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :custom_group_id, references(:custom_groups, on_delete: :nothing), null: false
      add :position, :integer

      timestamps()
    end

    create unique_index(:custom_group_member_users, [:custom_group_id, :user_id])
  end
end

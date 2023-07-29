defmodule Bright.Repo.Migrations.RenameRemoveWorkToRemoteWork do
  use Ecto.Migration

  def change do
    rename table(:user_job_profiles), :remove_work, to: :remote_work
  end
end

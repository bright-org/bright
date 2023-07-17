defmodule Bright.Repo.Migrations.AddIndexUserIdUserOnboardings do
  use Ecto.Migration

  def change do
    # user_onboardingsはオンボーディングは初回のみ登録可能なため、user_idはユニークにする
    drop_if_exists index(:user_onboardings, [:user_id])
    create unique_index(:user_onboardings, [:user_id])

    # created_atと同じ値が入るため不要なのでカラム削除
    alter table("user_onboardings") do
      remove_if_exists :completed_at, :naive_datetime
    end
  end
end

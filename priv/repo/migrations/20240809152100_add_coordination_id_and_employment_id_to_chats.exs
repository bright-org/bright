defmodule Bright.Repo.Migrations.AddCoordinationIdAndEmploymentIdToChats do
  use Ecto.Migration

  alias Bright.Chats.Chat
  alias Bright.Repo
  alias Bright.Recruits.Interview
  alias Bright.Recruits.Coordination
  alias Bright.Recruits.Employment
  import Ecto.Query, warn: false

  def up do
    alter table(:chats) do
      add :coordination_id, :uuid
      add :employment_id, :uuid
    end

    flush()

    convert_coordination()
    convert_employment()
  end

  def down do
    alter table(:chats) do
      remove :coordination_id
      remove :employment_id
    end
  end

  def convert_coordination do
    from(c in Chat,
      join: i in Interview,
      on:
        i.id == c.relation_id and
          i.status == :completed_interview,
      join: co in Coordination,
      on:
        i.recruiter_user_id == co.recruiter_user_id and
          i.updated_at <= co.inserted_at and
          co.inserted_at <= fragment("? + interval '10 seconds'", i.updated_at),
      where: c.relation_type == "interview",
      select: %{c | coordination: co}
    )
    |> Repo.all()
    |> Enum.each(fn x -> update_chat_coordination(x) end)
  end

  def update_chat_coordination(chat) do
    from(c in Chat, where: c.id == ^chat.id)
    |> Repo.update_all(set: [relation_id: chat.coordination.id, relation_type: "coordination"])
  end

  def convert_employment do
    from(c in Chat,
      join: co in Coordination,
      on:
        co.id == c.relation_id and
          co.status == :completed_coordination,
      join: e in Employment,
      on:
        co.recruiter_user_id == e.recruiter_user_id and
          co.updated_at <= e.inserted_at and
          e.inserted_at <= fragment("? + interval '10 seconds'", co.updated_at),
      where: c.relation_type == "coordination",
      select: %{c | employment: e}
    )
    |> Repo.all()
    |> Enum.each(fn x -> update_chat_employment(x) end)
  end

  def update_chat_employment(chat) do
    from(c in Chat, where: c.id == ^chat.id)
    |> Repo.update_all(set: [relation_id: chat.employment.id, relation_type: "employment"])
  end
end

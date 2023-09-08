defmodule Bright.Teams do
  @moduledoc """
  チームを操作するモジュール
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.Teams.Team
  alias Bright.Accounts.UserNotifier
  alias Bright.SkillScores.SkillClassScore

  # 招待メール関連定数
  @hash_algorithm :sha256
  @rand_size 32
  # TODO 要件調整 招待メールの期限1日
  @invitation_validity_ago 1

  @doc """
  Returns the list of teams.

  ## Examples

      iex> list_teams()
      [%Team{}, ...]

  """
  def list_teams do
    Repo.all(Team)
  end

  @doc """
  Gets a single team.

  Raises `Ecto.NoResultsError` if the Team does not exist.

  ## Examples

      iex> get_team_with_member_users!(123)
      %Team{}

      iex> get_team_with_member_users!(456)
      ** (Ecto.NoResultsError)

  """
  def get_team_with_member_users!(id) do
    Team
    |> preload(member_users: :user)
    |> Repo.get!(id)
  end

  @doc """
  Creates a team.

  ## Examples

      iex> create_team(%{field: value})
      {:ok, %Team{}}

      iex> create_team(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_team(attrs \\ %{}) do
    %Team{}
    |> Team.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a team.

  ## Examples

      iex> update_team(team, %{field: new_value})
      {:ok, %Team{}}

      iex> update_team(team, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_team(%Team{} = team, attrs) do
    team
    |> Team.registration_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a team.

  ## Examples

      iex> delete_team(team)
      {:ok, %Team{}}

      iex> delete_team(team)
      {:error, %Ecto.Changeset{}}

  """
  def delete_team(%Team{} = team) do
    Repo.delete(team)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking team changes.

  ## Examples

      iex> change_team(team)
      %Ecto.Changeset{data: %Team{}}

  """
  def change_team(%Team{} = team, attrs \\ %{}) do
    Team.changeset(team, attrs)
  end

  alias Bright.Teams.TeamMemberUsers

  @doc """
  Returns the list of team_member_users.

  ## Examples

      iex> list_team_member_users()
      [%TeamMemberUsers{}, ...]

  """
  def list_team_member_users do
    Repo.all(TeamMemberUsers)
  end

  @doc """
  Gets a single team_member_users.

  Raises `Ecto.NoResultsError` if the Team member users does not exist.

  ## Examples

      iex> get_team_member_users!(123)
      %TeamMemberUsers{}

      iex> get_team_member_users!(456)
      ** (Ecto.NoResultsError)

  """
  def get_team_member_users!(id), do: Repo.get!(TeamMemberUsers, id)

  @doc """
  Creates a team_member_users.

  ## Examples

      iex> create_team_member_users(%{field: value})
      {:ok, %TeamMemberUsers{}}

      iex> create_team_member_users(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_team_member_users(attrs \\ %{}) do
    %TeamMemberUsers{}
    |> TeamMemberUsers.changeset(attrs)
    |> Repo.insert()
  end

  def craete_team_member_users(attrs) do
    attrs
    |> Enum.each(fn x ->
      create_team_member_users(x)
    end)
  end

  @doc """
  Updates a team_member_users.

  ## Examples

      iex> update_team_member_users(team_member_users, %{field: new_value})
      {:ok, %TeamMemberUsers{}}

      iex> update_team_member_users(team_member_users, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_team_member_users(%TeamMemberUsers{} = team_member_users, attrs) do
    team_member_users
    |> TeamMemberUsers.changeset(attrs)
    |> Repo.update()
  end

  def update_team_member_users_invitation_confirmed_at(
        %TeamMemberUsers{} = team_member_users,
        attrs
      ) do
    team_member_users
    |> TeamMemberUsers.team_member_invitation_changeset(attrs)
    |> Repo.update()
  end

  def update_team_member_users_is_star(
        %TeamMemberUsers{} = team_member_users,
        attrs
      ) do
    team_member_users
    |> TeamMemberUsers.is_star_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a team_member_users.

  ## Examples

      iex> delete_team_member_users(team_member_users)
      {:ok, %TeamMemberUsers{}}

      iex> delete_team_member_users(team_member_users)
      {:error, %Ecto.Changeset{}}

  """
  def delete_team_member_users(%TeamMemberUsers{} = team_member_users) do
    Repo.delete(team_member_users)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking team_member_users changes.

  ## Examples

      iex> change_team_member_users(team_member_users)
      %Ecto.Changeset{data: %TeamMemberUsers{}}

  """
  def change_team_member_users(%TeamMemberUsers{} = team_member_users, attrs \\ %{}) do
    TeamMemberUsers.changeset(team_member_users, attrs)
  end

  @doc """
  ユーザーが所属するチームの一覧取得
  招待へ承認済のチームのみ対象
  Scrivenerのページングに対応

    iex> list_joined_teams_by_user_id(user_id, %{page: 1, page_size: 5})
      %Scrivener.Page{
        page_number: 1,
        page_size: 5,
        total_entries: 2,
        total_pages: 1,
        entries: [
          %Bright.Teams.TeamMemberUsers{},
        ]
      }
  """
  def list_joined_teams_by_user_id(user_id, page_param \\ %{page: 1, page_size: 1}) do
    from(tmbu in TeamMemberUsers,
      where: tmbu.user_id == ^user_id and not is_nil(tmbu.invitation_confirmed_at),
      order_by: [desc: tmbu.is_star, desc: tmbu.invitation_confirmed_at]
    )
    |> preload(:team)
    |> Repo.paginate(page_param)
  end

  def list_jined_users_and_skill_unit_scores_by_team_id(
        team_id,
        page_param \\ %{page: 1, page_size: 1}
      ) do
    from(tmbu in TeamMemberUsers,
      where: tmbu.team_id == ^team_id and not is_nil(tmbu.invitation_confirmed_at)
    )
    |> preload(user: [skill_class_scores: :skill_class])
    |> preload(user: [skill_unit_scores: :skill_unit])
    |> Repo.paginate(page_param)
  end

  @doc """
  チームメンバーの一覧取得
  自分自身も含めたい場合用
  Scrivenerのページングに対応
  """
  def list_joined_users_and_profiles_by_team_id(
        team_id,
        page_param \\ %{page: 1, page_size: 1}
      ) do
    from(tmu in TeamMemberUsers,
      where: tmu.team_id == ^team_id and not is_nil(tmu.invitation_confirmed_at),
      order_by: [
        desc: tmu.is_admin,
        asc: tmu.invitation_confirmed_at
      ]
    )
    |> preload(user: :user_profile)
    |> Repo.paginate(page_param)
  end

  def list_skill_scores_by_team_id(
        team_id,
        skill_panel_id,
        page_param \\ %{page: 1, page_size: 1}
      ) do
    team_member_users_query =
      from(
        tmu in TeamMemberUsers,
        where: tmu.team_id == ^team_id and not is_nil(tmu.invitation_confirmed_at),
        select: tmu.user_id
      )

    from(
      scs in SkillClassScore,
      join: sc in assoc(scs, :skill_class),
      on: scs.skill_class_id == sc.id,
      where:
        sc.skill_panel_id == ^skill_panel_id and scs.user_id in subquery(team_member_users_query)
    )
    |> preload(:skill_class)
    |> Repo.paginate(page_param)
  end

  @doc """
  チームメンバーの一覧取得
  自分自身を除外したい場合用
  """
  def list_joined_users_and_profiles_by_team_id_without_myself(
        user_id,
        team_id,
        page_param \\ %{page: 1, page_size: 1}
      ) do
    from(tmu in TeamMemberUsers,
      where:
        tmu.team_id == ^team_id and tmu.user_id != ^user_id and
          not is_nil(tmu.invitation_confirmed_at),
      order_by: [
        desc: tmu.is_admin,
        asc: tmu.invitation_confirmed_at
      ]
    )
    |> preload(user: :user_profile)
    |> Repo.paginate(page_param)
  end

  @spec create_team_multi(any, atom | %{:id => any, optional(any) => any}, any) :: any
  @doc """
  チームおよびメンバーの一括登録
  """
  def create_team_multi(name, admin_user, member_users) do
    team_attr = %{
      name: name,
      enable_hr_functions: false
    }

    # 作成者本人は自動的に管理者となる
    admin_attr = %{
      user_id: admin_user.id,
      is_admin: true,
      is_star: false,
      # 管理者本人は即時承認状態
      invitation_confirmed_at: TeamMemberUsers.now_for_confirmed_at()
    }

    member_attr =
      member_users
      |> Enum.map(fn member_user ->
        # 招待メール用のtokenを作成
        {base64_encoded_token, hashed_token} = build_invitation_token()

        %{
          user_id: member_user.id,
          is_admin: false,
          # メンバーのプライマリ判定は承認後に実施する為一旦falseとする
          is_star: false,
          invitation_token: hashed_token,
          invitation_sent_to: member_user.email,
          base64_encoded_token: base64_encoded_token
        }
      end)

    team_changeset =
      %Team{}
      |> Team.registration_changeset(team_attr)

    team_member_user_changesets =
      [admin_attr | member_attr]
      |> Enum.map(fn attrs ->
        change_team_member_users(%TeamMemberUsers{}, attrs)
      end)

    team_and_members_changeset =
      team_changeset
      |> Ecto.Changeset.put_assoc(:member_users, team_member_user_changesets)

    {:ok, result} =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:team, team_and_members_changeset)
      |> Repo.transaction()

    {:ok, Map.get(result, :team), member_attr}
  end

  @doc """
  チーム招待メール送信
  """
  def deliver_invitation_email_instructions(
        from_user,
        to_user,
        team,
        encoded_token,
        invite_team_url_fun
      )
      when is_function(invite_team_url_fun, 1) do
    UserNotifier.deliver_invitation_team_instructions(
      from_user,
      to_user,
      team,
      invite_team_url_fun.(encoded_token)
    )
  end

  @doc """
  チーム招待認証要token発行
  """
  def build_invitation_token() do
    token = :crypto.strong_rand_bytes(@rand_size)
    hashed_token = :crypto.hash(@hash_algorithm, token)
    base64_encoded_token = Base.url_encode64(token, padding: false)
    {base64_encoded_token, hashed_token}
  end

  @doc """
  チーム招待token取得
  """
  def get_invitation_token(invitation_token_base64_encoded) do
    case Base.url_decode64(invitation_token_base64_encoded, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)

        # 渡されたtokenを元に期限内の未認証レコードを取得
        days = @invitation_validity_ago

        team_member_user =
          from(tmbu in TeamMemberUsers,
            where: tmbu.invitation_token == ^hashed_token and tmbu.inserted_at > ago(^days, "day")
          )
          |> Repo.one()

        if team_member_user == nil do
          # 有効期限切れも含め対象のmember_userが存在しない場合は無効と判断
          :error
        else
          {:ok, team_member_user}
        end

      :error ->
        :error
    end
  end

  @doc """
  チーム招待承認
  """
  def confirm_invitation(team_member_user) do
    now = TeamMemberUsers.now_for_confirmed_at()

    {:ok, _team_member_user} =
      update_team_member_users_invitation_confirmed_at(team_member_user, %{
        invitation_confirmed_at: now
      })
  end

  def toggle_is_star(team_member_user) do
    {:ok, _team_member_user} =
      update_team_member_users_is_star(team_member_user, %{is_star: !team_member_user.is_star})
  end

  @doc """
  チームに所属しているかを確認
  """
  def joined_teams_by_user_id!(current_user_id, other_user_id) do
    from(tmbu in TeamMemberUsers,
      join: t in assoc(tmbu, :team),
      join: m in assoc(t, :member_users),
      where:
        tmbu.user_id == ^current_user_id and not is_nil(tmbu.invitation_confirmed_at) and
          m.user_id == ^other_user_id,
      select: m.user_id,
      distinct: true
    )
    |> Repo.one!()
  end
end

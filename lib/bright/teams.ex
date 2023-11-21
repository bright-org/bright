defmodule Bright.Teams do
  @moduledoc """
  チームを操作するモジュール
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.Teams.Team
  alias Bright.Accounts.UserNotifier
  alias Bright.Accounts.User

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

      iex> get_team!(123)
      %Team{}

      iex> get_team!(456)
      ** (Ecto.NoResultsError)

  """
  def get_team!(id) do
    Team
    |> where([t], is_nil(t.disabled_at))
    |> Repo.get!(id)
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
    |> where([t], is_nil(t.disabled_at))
    |> preload(member_users: :user)
    |> Repo.get!(id)
  end

  @doc """
  Gets a single team with users and user_profile.

  Raises `Ecto.NoResultsError` if the Team does not exist.

  ## Examples

      iex> get_team_with_member!(123)
      %Team{}

      iex> get_team_with_member!(456)
      ** (Ecto.NoResultsError)

  """

  def get_team_with_member!(id) do
    Team
    |> where([t], is_nil(t.disabled_at))
    |> preload(users: :user_profile)
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
  Returns the list of team_member_users invitated with given team
  """
  def list_confirmed_team_member_users_by_team(team) do
    TeamMemberUsers
    |> where([m], m.team_id == ^team.id)
    |> where([m], not is_nil(m.invitation_confirmed_at))
    |> Repo.all()
  end

  @doc """
  Returns the list of team_member_users find by team id and user id list.

  ## Examples

      iex> list_team_member_users_by_user_id(1, [1,2,3])
      [%TeamMemberUsers{}, ...]

  """
  def list_team_member_users_by_user_id(team_id, user_ids) do
    TeamMemberUsers
    |> where([m], m.team_id == ^team_id)
    |> where([m], m.user_id in ^user_ids)
    |> Repo.all()
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

  alias Bright.Teams.TeamSupporterTeam

  def list_team_supporter_team() do
    Repo.all(TeamSupporterTeam)
  end

  def get_team_supporter_team!(id) do
    Repo.get!(TeamSupporterTeam, id)
  end

  def delete_team_supporter_team(%TeamSupporterTeam{} = team) do
    Repo.delete(team)
  end

  def change_team_supporter_team(%TeamSupporterTeam{} = team, attrs \\ %{}) do
    TeamSupporterTeam.create_changeset(team, attrs)
  end

  @doc """
  Creates a team_supporter_team.

  ## Examples

      iex> create_team_supporter_team(%{field: value})
      {:ok, %TeamSupporterTeam{}}

      iex> create_team_supporter_team(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_team_supporter_team(attrs \\ %{}) do
    %TeamSupporterTeam{}
    |> TeamSupporterTeam.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a team_supporter_team.

  ## Examples

      iex> update_team_supporter_team(team_supporter_team, %{field: new_value})
      {:ok, %TeamMemberUsers{}}

      iex> update_team_supporter_team(team_supporter_team, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_team_supporter_team(%TeamSupporterTeam{} = team_supporter_team, attrs) do
    team_supporter_team
    |> TeamSupporterTeam.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  支援するチームの担当ユーザーIDをキーに自身に対する支援依頼の一覧を取得する
  支援依頼日時降順
  Scrivenerのページングに対応
  リクエスト時点ではsupporter_teamは未決定の為preloadしていない

  ## Examples

      iex> list_support_request_by_supporter_user_id(supporter_user_id, %{page: 1, page_size: 1})
      %Scrivener.Page{ page_number: 1, page_size: 1, total_entries: 2, total_pages: 2,
        entries: [
          %Bright.Teams.TeamSupporterTeam{
            supportee_team: %Bright.Teams.Team{},
            request_from_user: #Bright.Accounts.User{},
            request_to_user: #Bright.Accounts.User{},
          },
          ...
        ]
      }
  """
  def list_support_request_by_supporter_user_id(
        supporter_user_id,
        page_param \\ %{page: 1, page_size: 1}
      ) do
    from(tst in TeamSupporterTeam,
      where:
        tst.request_to_user_id == ^supporter_user_id and
          tst.status == :requesting,
      order_by: [
        desc: tst.request_datetime
      ]
    )
    |> preload(:request_from_user)
    |> preload(:request_to_user)
    |> preload(:supportee_team)
    |> Repo.paginate(page_param)
  end

  @doc """
  支援するチームの担当ユーザーIDをキーに自身が参加するチームの支援先チームの一覧を取得する
  支援開始日降順
  Scrivenerのページングに対応

  ## Examples

      iex> list_supportee_teams_by_supporter_user_id(supporter_user_id, %{page: 1, page_size: 1})
      %Scrivener.Page{page_number: 1, page_size: 1, total_entries: 0, total_pages: 1, entries: [%Bright.Teams.Team{}, ...]}

  """
  def list_supportee_teams_by_supporter_user_id(
        supporter_user_id,
        page_param \\ %{page: 1, page_size: 1}
      ) do
    from(tmu in TeamMemberUsers,
      left_join: tst in TeamSupporterTeam,
      on: tmu.team_id == tst.supporter_team_id,
      left_join: supporter_team in Team,
      on: tst.supporter_team_id == supporter_team.id,
      left_join: supportee_team in Team,
      on: tst.supportee_team_id == supportee_team.id,
      where:
        tmu.user_id == ^supporter_user_id and not is_nil(tmu.invitation_confirmed_at) and
          tst.status == :supporting,
      select: supportee_team,
      order_by: [
        desc: tst.start_datetime
      ]
    )
    |> Repo.paginate(page_param)
  end

  @doc """
  支援されるチームの担当ユーザーIDをキーに自チームを支援する人材・育成支援チームの一覧を取得する
  支援開始日降順
  Scrivenerのページングに対応

  ## Examples

      iex> list_supporter_teams_by_supportee_user_id(supportee_user_id, %{page: 1, page_size: 1})
      %Scrivener.Page{page_number: 1, page_size: 1, total_entries: 0, total_pages: 1, entries: [%Bright.Teams.Team{}, ...]}

  """
  def list_supporter_teams_by_supportee_user_id(
        supportee_user_id,
        page_param \\ %{page: 1, page_size: 1}
      ) do
    from(tmu in TeamMemberUsers,
      left_join: tst in TeamSupporterTeam,
      on: tmu.team_id == tst.supportee_team_id,
      left_join: supportee_team in Team,
      on: tst.supportee_team_id == supportee_team.id,
      left_join: supporter_team in Team,
      on: tst.supporter_team_id == supporter_team.id,
      where:
        tmu.user_id == ^supportee_user_id and not is_nil(tmu.invitation_confirmed_at) and
          tst.status == :supporting,
      select: supporter_team,
      order_by: [
        desc: tst.start_datetime
      ]
    )
    |> Repo.paginate(page_param)
  end

  @doc """
  ユーザーIDとチームIDを元に指定されたチームが支援中の支援チームまたは支援先チームであるかを判定する

  ## Examples

      iex> is_my_supportee_team_or_supporter_team(user_id, team_id)
      true

  """
  def is_my_supportee_team_or_supporter_team?(user_id, team_id) do
    # 自身の所属チームから関係するTeamSupporterTeamの取得して、支援先チーム、もしくは支援元チームのチームIDが指定されたチームIDを一致する件数が1件以上あれば支援関係ありと判断する
    [count] =
      from(tmu in TeamMemberUsers,
        left_join: supoutee_teams in TeamSupporterTeam,
        on:
          tmu.team_id == supoutee_teams.supportee_team_id and supoutee_teams.status == :supporting,
        left_join: supouter_teams in TeamSupporterTeam,
        on:
          tmu.team_id == supouter_teams.supporter_team_id and supouter_teams.status == :supporting,
        where:
          tmu.user_id ==
            ^user_id and not is_nil(tmu.invitation_confirmed_at) and
            (supoutee_teams.supporter_team_id == ^team_id or
               supouter_teams.supportee_team_id == ^team_id),
        select: count(tmu)
      )
      |> Repo.all()

    count > 0
  end

  @doc """
  支援されるチームから支援するチームへの支援依頼データを作成する

  ## Examples

      iex> request_support_from_suportee_team(supportee_team_id, supportee_user_id, supporter_user_id)
      {:ok, %Bright.Teams.TeamSupporterTeam{}}
      iex> request_support_from_suportee_team(invalid_supportee_team_id, invalid_supportee_user_id, invalid_supporter_user_id)
      {:error, %Ecto.Changeset{}}
  """
  def request_support_from_suportee_team(
        supportee_team_id,
        request_from_user_id,
        request_to_user_id
      ) do
    %{
      supportee_team_id: supportee_team_id,
      request_from_user_id: request_from_user_id,
      request_to_user_id: request_to_user_id,
      status: :requesting,
      request_datetime: NaiveDateTime.utc_now()
    }
    |> create_team_supporter_team()
  end

  @doc """
  支援するチームが支援依頼を承諾ステータスに更新する

  ## Examples

      iex> accept_support_by_supporter_team(teamSupporterTeam, supporter_team_id)
      {:ok, %Bright.Teams.TeamSupporterTeam{}}
      iex> accept_support_by_supporter_team(teamSupporterTeam, supporter_team_id)
      {:error, %Ecto.Changeset{}}
  """
  def accept_support_by_supporter_team(
        %Bright.Teams.TeamSupporterTeam{} = team_support_team,
        supporter_team_id
      ) do
    attrs = %{
      supporter_team_id: supporter_team_id,
      status: :supporting,
      start_datetime: NaiveDateTime.utc_now(),
      end_datetime: nil
    }

    team_support_team
    |> update_team_supporter_team(attrs)
  end

  @doc """
  支援するチームが支援依頼を拒否ステータスに更新する
  """
  def reject_support_by_supporter_team(%Bright.Teams.TeamSupporterTeam{} = team_support_team) do
    attrs = %{
      status: :reject
    }

    team_support_team
    |> update_team_supporter_team(attrs)
  end

  @doc """
  支援するチームが支援依頼を終了ステータスに更新する
  """
  def end_support_by_supporter_team(%Bright.Teams.TeamSupporterTeam{} = team_support_team) do
    attrs = %{
      status: :support_ended,
      end_datetime: NaiveDateTime.utc_now()
    }

    team_support_team
    |> update_team_supporter_team(attrs)
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
      left_join: t in assoc(tmbu, :team),
      where:
        tmbu.user_id == ^user_id and not is_nil(tmbu.invitation_confirmed_at) and
          is_nil(t.disabled_at),
      order_by: [desc: tmbu.is_star, desc: tmbu.invitation_confirmed_at]
    )
    |> preload(team: :member_users)
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

  @doc """
  ユーザーとチームメンバーになっているusers.idの一覧を返す
  （自分自身は含まない）
  """
  def list_user_ids_related_team_by_user(user) do
    Ecto.assoc(user, :teams)
    |> preload(:member_users)
    |> Repo.all()
    |> Enum.flat_map(fn team -> Enum.map(team.member_users, & &1.user_id) end)
    |> Enum.uniq()
    |> List.delete(user.id)
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

  iex> create_team_multi(
    name,
    admin_user,
    member_users,
      %{
          enable_team_up_functions: true,
          enable_hr_functions: false
      }
    )
  {:ok, team, team_member_user_attrs}

  """
  def create_team_multi(
        name,
        admin_user,
        member_users,
        enable_functions \\ %{enable_team_up_functions: false, enable_hr_functions: false}
      ) do
    team_attr = %{
      name: name,
      enable_team_up_functions: enable_functions.enable_team_up_functions,
      enable_hr_functions: enable_functions.enable_hr_functions
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
  チームおよびメンバーの一括更新

  iex> update_team_multi(
    team,
    update_params,
    admin_user,
    new_commer
    new_member_users,
      %{
          enable_team_up_functions: true,
          enable_hr_functions: false
      }
    )
  {:ok, team, team_member_user_attrs}

  """

  def update_team_multi(
        team,
        update_params,
        admin_user,
        newcomer,
        new_member_users,
        _enable_functions \\ %{enable_team_up_functions: false, enable_hr_functions: false}
      ) do
    member_attr =
      newcomer
      |> Enum.map(fn member_user ->
        # 招待メール用のtokenを作成
        {base64_encoded_token, hashed_token} = build_invitation_token()

        %TeamMemberUsers{
          user_id: member_user.id,
          is_admin: false,
          # メンバーのプライマリ判定は承認後に実施する為一旦falseとする
          is_star: false,
          invitation_token: hashed_token,
          invitation_sent_to: member_user.email,
          base64_encoded_token: base64_encoded_token
        }
      end)

    team_changeset = Team.registration_changeset(team, update_params)

    exists_member_ids =
      [admin_user | new_member_users -- newcomer]
      |> Enum.map(& &1.id)

    exists_members = list_team_member_users_by_user_id(team.id, exists_member_ids)

    team_member_user_changesets =
      [exists_members, member_attr]
      |> Enum.concat()
      |> Enum.map(fn attrs ->
        change_team_member_users(attrs)
      end)

    team_and_members_changeset =
      team_changeset
      |> Ecto.Changeset.put_assoc(:member_users, team_member_user_changesets)

    {:ok, result} =
      Ecto.Multi.new()
      |> Ecto.Multi.update(:team, team_and_members_changeset)
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
    if !Bright.Utils.Env.prod?() or Application.get_env(:bright, :dev_routes) do
      :ets.insert(
        :token,
        {"invite", to_user.email, to_user.name, invite_team_url_fun.(encoded_token)}
      )
    end

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
  所属していない場合Ecto.NoResultsErrorをraise
  """
  def joined_teams_by_user_id!(current_user_id, other_user_id) do
    query =
      from(tmbu in TeamMemberUsers,
        join: t in assoc(tmbu, :team),
        join: m in assoc(t, :member_users),
        where:
          tmbu.user_id == ^current_user_id and not is_nil(tmbu.invitation_confirmed_at) and
            m.user_id == ^other_user_id and not is_nil(m.invitation_confirmed_at),
        select: m.user_id,
        distinct: true
      )

    if Repo.exists?(query), do: true, else: raise(Ecto.NoResultsError, queryable: query)
  end

  @doc """
  チームに所属しているかを確認
  所属していない場合falseを返す
  """
  def joined_teams_by_user_id?(current_user_id, other_user_id) do
    joined_teams_by_user_id!(current_user_id, other_user_id)
    true
  rescue
    Ecto.NoResultsError -> false
  end

  @doc """
  指定されたcurrent_user_idに対して、other_user_idで指定されたユーザーがおなじチームに所属している、または支援先チーム、もしくは支援元チームに所属しているか確認
  所属している場合true
  所属していない場合Bright.Exceptions.ForbiddenResourceError(404扱い)をraise
  """
  def joined_teams_or_supportee_teams_or_supporter_teams_by_user_id!(
        current_user_id,
        other_user_id
      ) do
    if joined_teams_by_user_id?(current_user_id, other_user_id) ||
         joined_supportee_teams_or_supporter_teams_by_user_id?(current_user_id, other_user_id) do
      true
    else
      raise(Bright.Exceptions.ForbiddenResourceError)
    end
  end

  @doc """
  　自身の所属チームの支援元、支援先のチームに所属しているかを確認
  所属していない場合Ecto.NoResultsErrorをraise
  """
  def joined_supportee_teams_or_supporter_teams_by_user_id?(current_user_id, other_user_id) do
    query =
      from(tmu in TeamMemberUsers,
        left_join: supoutee_teams in TeamSupporterTeam,
        on:
          tmu.team_id == supoutee_teams.supporter_team_id and supoutee_teams.status == :supporting,
        left_join: supoutee_team in Team,
        on: supoutee_team.id == supoutee_teams.supportee_team_id,
        left_join: supoutee_team_members in TeamMemberUsers,
        on:
          supoutee_team_members.team_id == supoutee_team.id and
            not is_nil(supoutee_team_members.invitation_confirmed_at),
        left_join: supouter_teams in TeamSupporterTeam,
        on:
          tmu.team_id == supouter_teams.supportee_team_id and supouter_teams.status == :supporting,
        left_join: supouter_team in Team,
        on: supouter_team.id == supouter_teams.supporter_team_id,
        left_join: supouter_team_members in TeamMemberUsers,
        on:
          supouter_team_members.team_id == supouter_team.id and
            not is_nil(supouter_team_members.invitation_confirmed_at),
        where:
          tmu.user_id ==
            ^current_user_id and not is_nil(tmu.invitation_confirmed_at) and
            (supoutee_team_members.user_id == ^other_user_id or
               supouter_team_members.user_id == ^other_user_id),
        select: count(tmu)
      )

    [count] =
      query
      |> Repo.all()

    count > 0
  end

  def raise_if_not_ulid(team_id) do
    # チームIDの指定が不正だった場合は404で返す。
    Ecto.ULID.cast(team_id)
    |> case do
      {:ok, _} -> nil
      _ -> raise Ecto.NoResultsError, queryable: "Bright.Teams.Team"
    end
  end

  @doc """
    所属チームによる各種機能の利用可否判定を取得する
    - enable_team_up_functions チームスキル分析などチームアップ系機能の利用可否
    - enable_hr_functions 採用・人材支援等人材支援系機能の利用可否

    iex > get_enable_functions_by_joined_teams!(user_id)
    %{
      enable_team_up_functions: true,
      enable_hr_functions: false
    }

    iex > get_enable_functions_by_joined_teams!(not_exist_user_id)
    ** (Ecto.NoResultsError) expected at least one result but got none in query:

  """
  def get_enable_functions_by_joined_teams!(user_id) do
    # user_idをキーにenable_xxx_functionsフラグの立った所属チームの数を検索する
    {_user_id, enable_team_up_functions_count, enable_hr_functions_count} =
      get_count_enable_functions_by_joined_teams(user_id)

    # 各機能の利用可否の判定
    %{
      enable_team_up_functions: is_enable_by_count?(enable_team_up_functions_count),
      enable_hr_functions: is_enable_by_count?(enable_hr_functions_count)
    }
  end

  # Ectoのcountを使うと0件の場合のnilが返るのでnil=0件=権限なしと判定
  defp is_enable_by_count?(nil) do
    false
  end

  defp is_enable_by_count?(_count) do
    true
  end

  def get_count_enable_functions_by_joined_teams(user_id) do
    count_team_up_query = count_enable_team_up_function()
    count_hr_query = count_enable_hr_function()

    from(u in User,
      left_join: enable_team_up_functions in subquery(count_team_up_query),
      on: u.id == enable_team_up_functions.user_id,
      left_join: enable_hr_functions in subquery(count_hr_query),
      on: u.id == enable_hr_functions.user_id,
      where: u.id == ^user_id,
      select: {u.id, enable_team_up_functions.count, enable_hr_functions.count}
    )
    |> Repo.one!()
  end

  defp count_enable_hr_function() do
    from(tmu in TeamMemberUsers,
      left_join: t in assoc(tmu, :team),
      where: not is_nil(tmu.invitation_confirmed_at) and t.enable_hr_functions == true,
      select: %{user_id: tmu.user_id, count: count(tmu.user_id)},
      group_by: tmu.user_id
    )
  end

  defp count_enable_team_up_function() do
    from(tmu in TeamMemberUsers,
      left_join: t in assoc(tmu, :team),
      where: not is_nil(tmu.invitation_confirmed_at) and t.enable_team_up_functions == true,
      select: %{user_id: tmu.user_id, count: count(tmu.user_id)},
      group_by: tmu.user_id
    )
  end

  def count_admin_team(user_id) do
    from(
      tmu in TeamMemberUsers,
      left_join: t in assoc(tmu, :team),
      where: tmu.user_id == ^user_id and tmu.is_admin and is_nil(t.disabled_at)
    )
    |> Repo.aggregate(:count)
  end

  @doc """
  チームメンバーを並び替えて返す
  """
  def sort_team_member_users(team_member_users) do
    {stars, not_stars} = Enum.split_with(team_member_users, & &1.is_star)

    [stars, not_stars]
    |> Enum.flat_map(fn team_member_users ->
      Enum.sort_by(team_member_users, & &1.invitation_confirmed_at, {:asc, NaiveDateTime})
    end)
  end

  @doc """
  第一引数に応じてチームのタイプを判定する
  Bright.Teams.Teamの場合、teamsテーブルのenable_xx_functionsの状態に応じてタイプ判定
  Bright.CustomGroups.CustomGroupの場合、custom_groupとして判定
  """
  def get_team_type_by_team(%Bright.Teams.Team{} = team) do
    cond do
      team.enable_hr_functions == true ->
        # 現プラン仕様ではhr_support機能が使える最上位プランが採用・人材支援チームを作成可能という位置づけなので、enable_hr_functionsがtrueの場合は問答無用でhr_support_team判定する
        :hr_support_team

      team.enable_hr_functions == false and team.enable_team_up_functions == true ->
        # 上記条件に背反する条件として、hr_support_teamが使えなず、team_up_functionsだけが使えるのがteamup_teamという判定
        :teamup_team

      true ->
        :general_team
    end
  end

  def get_team_type_by_team(%Bright.CustomGroups.CustomGroup{}) do
    :custom_group
  end
end

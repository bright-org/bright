defmodule Bright.Subscriptions do
  @moduledoc """
  The Subscriptions context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo
  alias Bright.Accounts.UserNotifier
  alias Bright.Subscriptions.SubscriptionPlan

  @create_teams_limit_without_plan 1
  @create_enable_hr_functions_teams_limit_without_plan 0
  @team_members_limit_without_plan 5

  def get_create_teams_limit(nil), do: @create_teams_limit_without_plan

  def get_create_teams_limit(subscription_plan) do
    subscription_plan.create_teams_limit
  end

  def get_create_enable_hr_functions_teams_limit(nil),
    do: @create_enable_hr_functions_teams_limit_without_plan

  def get_create_enable_hr_functions_teams_limit(subscription_plan) do
    subscription_plan.create_enable_hr_functions_teams_limit
  end

  def get_team_members_limit(nil), do: @team_members_limit_without_plan

  def get_team_members_limit(subscription_plan) do
    subscription_plan.team_members_limit
  end

  @doc """
  Returns the list of subscription_plans.

  ## Examples

      iex> list_subscription_plans()
      [%SubscriptionPlan{}, ...]

  """
  def list_subscription_plans do
    Repo.all(SubscriptionPlan)
  end

  @doc """
  Gets a single subscription_plan.

  Raises `Ecto.NoResultsError` if the Subscription plan does not exist.

  ## Examples

      iex> get_subscription_plan!(123)
      %SubscriptionPlan{}

      iex> get_subscription_plan!(456)
      ** (Ecto.NoResultsError)

  """
  def get_subscription_plan!(id), do: Repo.get!(SubscriptionPlan, id)

  @doc """
  Creates a subscription_plan.

  ## Examples

      iex> create_subscription_plan(%{field: value})
      {:ok, %SubscriptionPlan{}}

      iex> create_subscription_plan(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_subscription_plan(attrs \\ %{}) do
    %SubscriptionPlan{}
    |> SubscriptionPlan.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a subscription_plan.

  ## Examples

      iex> update_subscription_plan(subscription_plan, %{field: new_value})
      {:ok, %SubscriptionPlan{}}

      iex> update_subscription_plan(subscription_plan, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_subscription_plan(%SubscriptionPlan{} = subscription_plan, attrs) do
    subscription_plan
    |> SubscriptionPlan.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a subscription_plan.

  ## Examples

      iex> delete_subscription_plan(subscription_plan)
      {:ok, %SubscriptionPlan{}}

      iex> delete_subscription_plan(subscription_plan)
      {:error, %Ecto.Changeset{}}

  """
  def delete_subscription_plan(%SubscriptionPlan{} = subscription_plan) do
    Repo.delete(subscription_plan)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking subscription_plan changes.

  ## Examples

      iex> change_subscription_plan(subscription_plan)
      %Ecto.Changeset{data: %SubscriptionPlan{}}

  """
  def change_subscription_plan(%SubscriptionPlan{} = subscription_plan, attrs \\ %{}) do
    SubscriptionPlan.changeset(subscription_plan, attrs)
  end

  alias Bright.Subscriptions.SubscriptionPlanService

  @doc """
  Returns the list of subscription_plan_services.

  ## Examples

      iex> list_subscription_plan_services()
      [%SubscriptionPlanService{}, ...]

  """
  def list_subscription_plan_services do
    Repo.all(SubscriptionPlanService)
  end

  @doc """
  Gets a single subscription_plan_service.

  Raises `Ecto.NoResultsError` if the Subscription plan service does not exist.

  ## Examples

      iex> get_subscription_plan_service!(123)
      %SubscriptionPlanService{}

      iex> get_subscription_plan_service!(456)
      ** (Ecto.NoResultsError)

  """
  def get_subscription_plan_service!(id), do: Repo.get!(SubscriptionPlanService, id)

  @doc """
  Creates a subscription_plan_service.

  ## Examples

      iex> create_subscription_plan_service(%{field: value})
      {:ok, %SubscriptionPlanService{}}

      iex> create_subscription_plan_service(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_subscription_plan_service(attrs \\ %{}) do
    %SubscriptionPlanService{}
    |> SubscriptionPlanService.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a subscription_plan_service.

  ## Examples

      iex> update_subscription_plan_service(subscription_plan_service, %{field: new_value})
      {:ok, %SubscriptionPlanService{}}

      iex> update_subscription_plan_service(subscription_plan_service, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_subscription_plan_service(
        %SubscriptionPlanService{} = subscription_plan_service,
        attrs
      ) do
    subscription_plan_service
    |> SubscriptionPlanService.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a subscription_plan_service.

  ## Examples

      iex> delete_subscription_plan_service(subscription_plan_service)
      {:ok, %SubscriptionPlanService{}}

      iex> delete_subscription_plan_service(subscription_plan_service)
      {:error, %Ecto.Changeset{}}

  """
  def delete_subscription_plan_service(%SubscriptionPlanService{} = subscription_plan_service) do
    Repo.delete(subscription_plan_service)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking subscription_plan_service changes.

  ## Examples

      iex> change_subscription_plan_service(subscription_plan_service)
      %Ecto.Changeset{data: %SubscriptionPlanService{}}

  """
  def change_subscription_plan_service(
        %SubscriptionPlanService{} = subscription_plan_service,
        attrs \\ %{}
      ) do
    SubscriptionPlanService.changeset(subscription_plan_service, attrs)
  end

  alias Bright.Subscriptions.SubscriptionUserPlan

  @doc """
  Returns the list of subscription_user_plans.

  ## Examples

      iex> list_subscription_user_plans()
      [%SubscriptionUserPlan{}, ...]

  """
  def list_subscription_user_plans do
    Repo.all(SubscriptionUserPlan)
  end

  def list_subscription_user_plans_with_plan do
    SubscriptionUserPlan
    |> preload([:subscription_plan, :user])
    |> Repo.all()
  end

  @doc """
  Gets a single subscription_user_plan.

  Raises `Ecto.NoResultsError` if the Subscription user plan does not exist.

  ## Examples

      iex> get_subscription_user_plan!(123)
      %SubscriptionUserPlan{}

      iex> get_subscription_user_plan!(456)
      ** (Ecto.NoResultsError)

  """
  def get_subscription_user_plan!(id), do: Repo.get!(SubscriptionUserPlan, id)

  def get_subscription_user_plan_with_plan!(id) do
    SubscriptionUserPlan
    |> preload([:subscription_plan, :user])
    |> Repo.get!(id)
  end

  @doc """
  Creates a subscription_user_plan.

  ## Examples

      iex> create_subscription_user_plan(%{field: value})
      {:ok, %SubscriptionUserPlan{}}

      iex> create_subscription_user_plan(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_subscription_user_plan(attrs \\ %{}) do
    %SubscriptionUserPlan{}
    |> SubscriptionUserPlan.changeset(attrs)
    |> Repo.insert()
  end

  def create_free_trial_subscription_user_plan(attrs \\ %{}) do
    %SubscriptionUserPlan{}
    |> SubscriptionUserPlan.trial_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a subscription_user_plan.

  ## Examples

      iex> update_subscription_user_plan(subscription_user_plan, %{field: new_value})
      {:ok, %SubscriptionUserPlan{}}

      iex> update_subscription_user_plan(subscription_user_plan, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_subscription_user_plan(%SubscriptionUserPlan{} = subscription_user_plan, attrs) do
    subscription_user_plan
    |> SubscriptionUserPlan.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a subscription_user_plan.

  ## Examples

      iex> delete_subscription_user_plan(subscription_user_plan)
      {:ok, %SubscriptionUserPlan{}}

      iex> delete_subscription_user_plan(subscription_user_plan)
      {:error, %Ecto.Changeset{}}

  """
  def delete_subscription_user_plan(%SubscriptionUserPlan{} = subscription_user_plan) do
    Repo.delete(subscription_user_plan)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking subscription_user_plan changes.

  ## Examples

      iex> change_subscription_user_plan(subscription_user_plan)
      %Ecto.Changeset{data: %SubscriptionUserPlan{}}

  """
  def change_subscription_user_plan(
        %SubscriptionUserPlan{} = subscription_user_plan,
        attrs \\ %{}
      ) do
    SubscriptionUserPlan.changeset(subscription_user_plan, attrs)
  end

  @doc """
  プランコードを引数にサブスクリプションプランを取得する

  ## Examples

      iex> get_plan_by_plan_code("team_up_plan")
      %SubscriptionPlan{}
      iex> get_plan_by_plan_code("hogehoge")
      nil
  """
  def get_plan_by_plan_code(plan_code) do
    SubscriptionPlan
    |> Repo.get_by(plan_code: plan_code)
  end

  @doc """
  サービスコードを指定してサブスクリプションプランサービスを削除する

  ## Examples

      iex> delete_subscription_plan_service_by_service_code("team_up")
      {2, nil}
  """
  def delete_subscription_plan_service_by_service_code(service_code) do
    from(sup in SubscriptionPlanService,
      where: sup.service_code == ^service_code
    )
    |> Repo.delete_all()
  end

  @doc """
  プランコードを指定してサブスクリプションプランと、プランで有効なサービス一覧を取得する

  ## Examples
      iex> get_subscription_plan_with_enable_services_by_plan_code("together")
      %SubscriptionPlan{}
  """
  def get_subscription_plan_with_enable_services_by_plan_code(plan_code) do
    from(sp in SubscriptionPlan,
      where: sp.plan_code == ^plan_code
    )
    |> preload(:subscription_plan_services)
    |> Repo.one()
  end

  @doc """
  プランを指定してフリートライアルを開始する

  ## Examples
      iex> start_free_trial( "01H7W3BZQY7CZVM5Q66T4EWEVC", "01HBQM1K1BVCGSMMH8511MWG40")
      {:ok,
        %SubscriptionUserPlan{}
      }

  """
  def start_free_trial(user_id, subscription_plan_id, trial_data) do
    trial_start_datetime = NaiveDateTime.utc_now()

    %{
      user_id: user_id,
      subscription_plan_id: subscription_plan_id,
      subscription_status: :free_trial,
      trial_start_datetime: trial_start_datetime
    }
    |> Map.merge(trial_data)
    |> create_free_trial_subscription_user_plan()
  end

  @doc """
  プランを指定してプランの有料利用を開始する

  ## Examples
      iex> start_subscription( "01H7W3BZQY7CZVM5Q66T4EWEVC", "01HBQM1K1BVCGSMMH8511MWG40")
      {:ok,
        %SubscriptionUserPlan{}
      }
  """
  def start_subscription(user_id, subscription_plan_id) do
    start_datetime = NaiveDateTime.utc_now()

    %{
      user_id: user_id,
      subscription_plan_id: subscription_plan_id,
      subscription_status: :subscribing,
      subscription_start_datetime: start_datetime
    }
    |> create_subscription_user_plan()
  end

  @doc """
  ユーザーの現プランを返す
  契約かトライアルかに関わらず最も上位のプランが対象

  ## Examples
      iex> get_user_subscription_user_plan("01H7W3BZQY7CZVM5Q66T4EWEVC")
      %Bright.Subscriptions.SubscriptionUserPlan{}
      iex> get_user_subscription_user_plan("01H7W3BZQY7CZVM5Q66T4EWEVC")
      nil
      iex> get_user_subscription_user_plan(["01H7W3BZQY7CZVM5Q66T4EWEVC"])
      [%Bright.Subscriptions.SubscriptionUserPlan{}]
      iex> get_user_subscription_user_plan(["01H7W3BZQY7CZVM5Q66T4EWEVC"])
      []

  """
  def get_user_subscription_user_plan(user_ids) when is_list(user_ids) do
    current_datetime = NaiveDateTime.utc_now()
    limit = length(user_ids)

    from(sup in SubscriptionUserPlan,
      where: sup.user_id in ^user_ids,
      where:
        (sup.subscription_start_datetime <= ^current_datetime and
           is_nil(sup.subscription_end_datetime)) or
          (sup.trial_start_datetime <= ^current_datetime and is_nil(sup.trial_end_datetime)),
      join: sp in assoc(sup, :subscription_plan),
      order_by: {:desc, sp.authorization_priority},
      preload: [subscription_plan: {sp, [:subscription_plan_services]}],
      limit: ^limit
    )
    |> Repo.all()
  end

  def get_user_subscription_user_plan(user_id) do
    current_datetime = NaiveDateTime.utc_now()

    from(sup in SubscriptionUserPlan,
      where: sup.user_id == ^user_id,
      where:
        (sup.subscription_start_datetime <= ^current_datetime and
           is_nil(sup.subscription_end_datetime)) or
          (sup.trial_start_datetime <= ^current_datetime and is_nil(sup.trial_end_datetime)),
      join: sp in assoc(sup, :subscription_plan),
      order_by: {:desc, sp.authorization_priority},
      preload: [subscription_plan: {sp, [:subscription_plan_services]}],
      limit: 1
    )
    |> Repo.one()
  end

  @doc """
  ユーザーIDと基準時刻をキーに有効な契約内容を取得する

  ## Examples
      iex> get_users_subscription_status("01H7W3BZQY7CZVM5Q66T4EWEVC", NaiveDateTime.utc_now())
      %Bright.Subscriptions.SubscriptionUserPlan{}
      iex> get_users_subscription_status("01H7W3BZQY7CZVM5Q66T4EWEVC", NaiveDateTime.utc_now())
      nil
  """
  def get_users_subscription_status(user_id, base_datetime) do
    # free_trialの有無に関わらず、契約終了日がnilの契約を有効とみなす
    # 複数プランが対象になるとき（例: 契約中かつ無料トライアル中）は、
    # authorization_priorityに基づいて権限が広範な契約内容を返す
    from(sup in SubscriptionUserPlan,
      where:
        sup.user_id == ^user_id and sup.subscription_start_datetime <= ^base_datetime and
          is_nil(sup.subscription_end_datetime),
      join: sp in assoc(sup, :subscription_plan),
      order_by: {:desc, sp.authorization_priority},
      preload: [subscription_plan: {sp, [:subscription_plan_services]}],
      limit: 1
    )
    |> Repo.one()
  end

  @doc """
  サービスコードをキーに該当サービスの利用可否を返す

  ## Examples
      iex> service_enabled?("01H7W3BZQY7CZVM5Q66T4EWEVC", "hogehoge")
      false
      iex> service_enabled?("01H7W3BZQY7CZVM5Q66T4EWEVC", "skill_up")
      true
      iex> service_enabled?(["01H7W3BZQY7CZVM5Q66T4EWEVC"], "hogehoge")
      false
      iex> service_enabled?(["01H7W3BZQY7CZVM5Q66T4EWEVC"], "skill_up")
      true
  """

  def service_enabled?(user_ids, service_code) when is_list(user_ids) do
    subscription_user_plans = get_user_subscription_user_plan(user_ids)

    case subscription_user_plans do
      [] ->
        false

      _ ->
        subscription_user_plans
        |> Enum.map(fn plan ->
          plan.subscription_plan.subscription_plan_services
          |> Enum.any?(&(&1.service_code == service_code))
        end)
        |> Enum.any?()
    end
  end

  def service_enabled?(user_id, service_code) do
    subscription_user_plan = get_user_subscription_user_plan(user_id)

    case subscription_user_plan do
      %SubscriptionUserPlan{} ->
        subscription_user_plan.subscription_plan.subscription_plan_services
        |> Enum.any?(fn subscription_plan_service ->
          subscription_plan_service.service_code == service_code
        end)

      _ ->
        false
    end
  end

  @doc """
  ユーザーIDをキーに採用、育成の基本サービスの利用可否を返す

  ## Examples
      iex> service_hr_basic_enabled?("01H7W3BZQY7CZVM5Q66T4EWEVC")
      true
  """
  def service_hr_basic_enabled?(user_id) do
    service_enabled?(user_id, "hr_basic")
  end

  @doc """
  ユーザーIDをキーにチームアップサービスの利用可否を返す

  ## Examples
      iex> service_team_up_enabled?("01H7W3BZQY7CZVM5Q66T4EWEVC")
      true
  """
  def service_team_up_enabled?(user_id) do
    service_enabled?(user_id, "team_up")
  end

  @doc """
  サービスコードをキーに該当サービスが最も優先度の高いサブスクリプションプランを返す

  現契約プランが渡された場合は、ダウングレードを避けるためにチーム作成可能数などの条件を追加している

  ## Examples
    iex> get_most_priority_free_trial_subscription_plan("team_up")
    %SubscriptionPlan{}
    iex> get_most_priority_free_trial_subscription_plan("hogheoge")
    nil
  """
  def get_most_priority_free_trial_subscription_plan_by_service(service_code, current_plan \\ nil)

  def get_most_priority_free_trial_subscription_plan_by_service(service_code, nil) do
    from(sp in SubscriptionPlan,
      join: sps in assoc(sp, :subscription_plan_services),
      where: sps.service_code == ^service_code,
      where: not is_nil(sp.free_trial_priority),
      order_by: [asc: sp.free_trial_priority],
      limit: 1
    )
    |> Repo.one()
  end

  def get_most_priority_free_trial_subscription_plan_by_service(service_code, current_plan) do
    from(sp in SubscriptionPlan,
      join: sps in assoc(sp, :subscription_plan_services),
      where: sps.service_code == ^service_code,
      where: sp.create_teams_limit >= ^current_plan.create_teams_limit,
      where:
        sp.create_enable_hr_functions_teams_limit >=
          ^current_plan.create_enable_hr_functions_teams_limit,
      where: sp.team_members_limit >= ^current_plan.team_members_limit,
      where: not is_nil(sp.free_trial_priority),
      order_by: [asc: sp.free_trial_priority],
      limit: 1
    )
    |> Repo.one()
  end

  @doc """
  チーム作成上限数を満たす最も優先度の高いサブスクリプションプランを返す

  現プランがある場合は
  - create_teams_limitが大、かつ
  - 上位のauthorization_priorityをもつ（ダウングレード防止）
  が対象
  """
  def get_most_priority_free_trial_subscription_plan_by_teams_limit(
        create_teams_limit,
        current_plan \\ nil
      )

  def get_most_priority_free_trial_subscription_plan_by_teams_limit(create_teams_limit, nil) do
    from(sp in SubscriptionPlan,
      where: sp.create_teams_limit >= ^create_teams_limit,
      where: not is_nil(sp.free_trial_priority),
      order_by: [asc: sp.free_trial_priority],
      limit: 1
    )
    |> Repo.one()
  end

  def get_most_priority_free_trial_subscription_plan_by_teams_limit(
        _create_teams_limit,
        current_plan
      ) do
    from(sp in SubscriptionPlan,
      where: sp.create_teams_limit > ^current_plan.create_teams_limit,
      where:
        sp.create_enable_hr_functions_teams_limit >=
          ^current_plan.create_enable_hr_functions_teams_limit,
      where: sp.team_members_limit >= ^current_plan.team_members_limit,
      where: sp.authorization_priority >= ^current_plan.authorization_priority,
      where: not is_nil(sp.free_trial_priority),
      order_by: [asc: sp.free_trial_priority],
      limit: 1
    )
    |> Repo.one()
  end

  @doc """
  採用・育成支援チーム作成上限数を満たす最も優先度の高いサブスクリプションプランを返す

  現プランがある場合は
  - create_enable_hr_functions_teams_limitが大、かつ
  - 上位のauthorization_priorityをもつ（ダウングレード防止）
  が対象
  """
  def get_most_priority_free_trial_subscription_plan_by_hr_support_teams_limit(
        create_enable_hr_functions_teams_limit,
        current_plan \\ nil
      )

  def get_most_priority_free_trial_subscription_plan_by_hr_support_teams_limit(
        create_enable_hr_functions_teams_limit,
        nil
      ) do
    from(sp in SubscriptionPlan,
      where: sp.create_enable_hr_functions_teams_limit >= ^create_enable_hr_functions_teams_limit,
      where: not is_nil(sp.free_trial_priority),
      order_by: [asc: sp.free_trial_priority],
      limit: 1
    )
    |> Repo.one()
  end

  def get_most_priority_free_trial_subscription_plan_by_hr_support_teams_limit(
        _create_enable_hr_functions_teams_limit,
        current_plan
      ) do
    from(sp in SubscriptionPlan,
      where:
        sp.create_enable_hr_functions_teams_limit >
          ^current_plan.create_enable_hr_functions_teams_limit,
      where: sp.create_teams_limit >= ^current_plan.create_teams_limit,
      where: sp.team_members_limit >= ^current_plan.team_members_limit,
      where: sp.authorization_priority >= ^current_plan.authorization_priority,
      where: not is_nil(sp.free_trial_priority),
      order_by: [asc: sp.free_trial_priority],
      limit: 1
    )
    |> Repo.one()
  end

  @doc """
  メンバー上限数を満たす最も優先度の高いサブスクリプションプランを返す

  現プランがある場合は
  - team_members_limitが大、かつ
  - 上位のauthorization_priorityをもつ（ダウングレード防止）
  が対象
  """
  def get_most_priority_free_trial_subscription_plan_by_members_limit(
        team_members_limit,
        current_plan \\ nil
      )

  def get_most_priority_free_trial_subscription_plan_by_members_limit(team_members_limit, nil) do
    from(sp in SubscriptionPlan,
      where: sp.team_members_limit >= ^team_members_limit,
      where: not is_nil(sp.free_trial_priority),
      order_by: [asc: sp.free_trial_priority],
      limit: 1
    )
    |> Repo.one()
  end

  def get_most_priority_free_trial_subscription_plan_by_members_limit(
        _team_members_limit,
        current_plan
      ) do
    from(sp in SubscriptionPlan,
      where: sp.team_members_limit > ^current_plan.team_members_limit,
      where: sp.create_teams_limit >= ^current_plan.create_teams_limit,
      where:
        sp.create_enable_hr_functions_teams_limit >=
          ^current_plan.create_enable_hr_functions_teams_limit,
      where: sp.authorization_priority >= ^current_plan.authorization_priority,
      where: not is_nil(sp.free_trial_priority),
      order_by: [asc: sp.free_trial_priority],
      limit: 1
    )
    |> Repo.one()
  end

  @doc """
  フリートライアル済のプラン一覧を返す

   ## Examples
      iex> get_users_trialed_plans("01H7W3BZQY7CZVM5Q66T4EWEVC")
      [
        %Bright.Subscriptions.SubscriptionUserPlan{}, ...
      ]
  """
  def get_users_trialed_plans(user_id) do
    from(sup in SubscriptionUserPlan,
      where: sup.user_id == ^user_id and not is_nil(sup.trial_start_datetime),
      order_by: [asc: sup.trial_start_datetime]
    )
    |> preload(:subscription_plan)
    |> Repo.all()
  end

  @doc """
  終了したプラン一覧を返す

   ## Examples
      iex> get_users_expired_plans("01H7W3BZQY7CZVM5Q66T4EWEVC")
      [
        %Bright.Subscriptions.SubscriptionUserPlan{}, ...
      ]
  """
  def get_users_expired_plans(user_id) do
    from(sup in SubscriptionUserPlan,
      where: sup.user_id == ^user_id and not is_nil(sup.subscription_end_datetime),
      order_by: [asc: sup.trial_start_datetime]
    )
    |> preload(:subscription_plan)
    |> Repo.all()
  end

  @doc """
  プランコードをキーに該当プランのフリートライアル利用可否を返す

  下記条件下では利用できない

  - 現在該当プランのサービスを内包するフリートライアル中か契約中である
  - 過去に一度でも該当プランでフリートライアルや契約をしている
    - 同一プランが対象（上位プランが既に済みでも利用可能）
  - 指定されたプランが無料トライアル対象ではない（`free_trial_priority`が設定されていない）

  ## Examples
      iex> free_trial_available?("01H7W3BZQY7CZVM5Q66T4EWEVC", "hogehoge")
      {true, nil}
      iex> free_trial_available?("01H7W3BZQY7CZVM5Q66T4EWEVC", "together")
      {false, :already_available}
      iex> free_trial_available?("01H7W3BZQY7CZVM5Q66T4EWEVC", "together")
      {false, :already_used_once}
  """
  def free_trial_available?(user_id, plan_code) do
    # ユーザーの契約履歴を洗って、現状と過去に分けている
    {currents, olds} = list_subscription_user_plans_history(user_id)

    current =
      if currents != [], do: Enum.max_by(currents, & &1.subscription_plan.authorization_priority)

    already_available? =
      subscription_user_plan_is_already_available?(
        current && current.subscription_plan,
        plan_code
      )

    already_used_once? = Enum.any?(olds, &(&1.subscription_plan.plan_code == plan_code))

    target_plan = get_plan_by_plan_code(plan_code)

    not_for_trial? =
      Enum.any?([
        target_plan.free_trial_priority == nil,
        current && current.subscription_plan.free_trial_priority == nil
      ])

    cond do
      not_for_trial? -> {false, :not_for_trial}
      already_available? -> {false, :already_available}
      already_used_once? -> {false, :already_used_once}
      true -> {true, nil}
    end
  end

  defp list_subscription_user_plans_history(user_id) do
    from(sup in SubscriptionUserPlan,
      where: sup.user_id == ^user_id,
      join: sp in assoc(sup, :subscription_plan),
      preload: [subscription_plan: {sp, :subscription_plan_services}]
    )
    |> Repo.all()
    |> Enum.split_with(
      &((&1.subscription_start_datetime && &1.subscription_end_datetime == nil) ||
          (&1.trial_start_datetime && &1.trial_end_datetime == nil))
    )
  end

  defp subscription_user_plan_is_already_available?(nil, _plan_code), do: false

  defp subscription_user_plan_is_already_available?(subscription_plan, plan_code) do
    # プランが指定したプランを内包するかどうかを返す
    #
    # 内包判定
    # - service_codeをすべて満たす
    # - limitの制限をすべて満たす
    target_plan =
      get_plan_by_plan_code(plan_code)
      |> Repo.preload(:subscription_plan_services)

    target_service_codes = Enum.map(target_plan.subscription_plan_services, & &1.service_code)
    service_codes = Enum.map(subscription_plan.subscription_plan_services, & &1.service_code)
    has_services? = target_service_codes -- service_codes == []

    has_limit? =
      ~w(create_teams_limit create_enable_hr_functions_teams_limit team_members_limit)a
      |> Enum.map(&(Map.get(subscription_plan, &1) >= Map.get(target_plan, &1)))
      |> Enum.all?()

    has_services? && has_limit?
  end

  def deliver_free_trial_apply_instructions(from_user, application_detail) do
    UserNotifier.deliver_free_trial_apply_instructions(
      from_user,
      application_detail
    )
  end

  @doc """
  組織プランかどうかを返す

  申し込み時に会社名を必要とするかといった判断で利用
  サービス内容の実態はsubscription_plan_servicesでもつため、service_codeの有無で判定する
  """
  def organization_plan?(subscription_plan) do
    subscription_plan
    |> Repo.preload(:subscription_plan_services)
    |> Map.get(:subscription_plan_services)
    |> Enum.any?(&(&1.service_code == "team_up"))
  end
end

defmodule Bright.Subscriptions do
  @moduledoc """
  The Subscriptions context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo
  alias Bright.Subscriptions.SubscriptionPlan
  alias Bright.Accounts.User

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

      iex> get_plan_by_plan_code("free_plan")
      %SubscriptionPlan{}
      iex> get_plan_by_plan_code("hogehoge")
      nil
  """
  def get_plan_by_plan_code(plan_code) do
    SubscriptionPlan
    |> Repo.get_by(plan_code: plan_code)
  end

  @doc """
  サービスコードを指定してサブスクリプションプランを削除する

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
  プランコードを指定してサブスクリプションプラント、プランで有効なサービス一覧を取得する

  ## Examples
      iex> get_subscription_plan_with_enable_services_by_plan_code("personal_skill_up_plan")
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
  def start_free_trial(user_id, subscription_plan_id) do
    trial_start_datetime = NaiveDateTime.utc_now()

    %{
      user_id: user_id,
      subscription_plan_id: subscription_plan_id,
      subscription_status: :free_trial,
      trial_start_datetime: trial_start_datetime,
      subscription_start_datetime: trial_start_datetime
    }
    |> create_subscription_user_plan()
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
    trial_start_datetime = NaiveDateTime.utc_now()

    %{
      user_id: user_id,
      subscription_plan_id: subscription_plan_id,
      subscription_status: :subscribing,
      subscription_start_datetime: trial_start_datetime
    }
    |> create_subscription_user_plan()
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
    from(sup in SubscriptionUserPlan,
      where:
        sup.user_id == ^user_id and sup.subscription_start_datetime <= ^base_datetime and
          is_nil(sup.subscription_end_datetime)
    )
    |> preload(subscription_plan: :subscription_plan_services)
    |> Repo.one()
  end

  @doc """
  サービスコードをキーに該当サービスの利用有無を返す

  ## Examples
      iex> enable_service?("01H7W3BZQY7CZVM5Q66T4EWEVC", "hogehoge")
      false
      iex> enable_service?("01H7W3BZQY7CZVM5Q66T4EWEVC", "skill_up")
      true
  """
  def enable_service?(user_id, service_code) do
    subscription_user_plan = get_users_subscription_status(user_id, NaiveDateTime.utc_now())

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
  サービスコードをキーに該当サービスが利用可能な最も優先度の高いサブスクリプションプランを返す

  ## Examples
    iex> get_most_priority_free_trial_subscription_plan("team_up")
    %SubscriptionPlan{}
    iex> get_most_priority_free_trial_subscription_plan("hogheoge")
    nil
  """
  def get_most_priority_free_trial_subscription_plan(service_code) do
    from(sp in SubscriptionPlan,
      join: sps in assoc(sp, :subscription_plan_services),
      where: sps.service_code == ^service_code,
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
  プランコードをキーに該当プランのフリートライアル利用有無を返す
  過去に一度でも該当のプランでフリートライアルを開始した履歴がある場合、利用不可

  ## Examples
      iex> enable_free_trial?("01H7W3BZQY7CZVM5Q66T4EWEVC", "hogehoge")
      true
      iex> enable_service?("01H7W3BZQY7CZVM5Q66T4EWEVC", "personal_skill_up_plan")
      false
  """
  def available_free_trial?(user_id, plan_code) do
    get_users_trialed_plans(user_id)
    |> Enum.any?(fn subscription_user_plan ->
      subscription_user_plan.subscription_plan.plan_code == plan_code
    end)
    |> Kernel.not()
  end
end

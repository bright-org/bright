defmodule Bright.SkillEvidences do
  @moduledoc """
  The SkillEvidences context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.SkillEvidences.{SkillEvidence, SkillEvidencePost}
  alias Bright.Teams
  alias Bright.Notifications
  alias Bright.SkillUnits
  alias Bright.Utils.Percentage
  alias Bright.Utils.GoogleCloud.Storage

  @doc """
  Returns the list of skill_evidences.

  ## Examples

      iex> list_skill_evidences()
      [%SkillEvidence{}, ...]

  """
  def list_skill_evidences do
    Repo.all(SkillEvidence)
  end

  @doc """
  直近のコメント順に学習メモを返す
  """
  def list_recent_skill_evidences(user_ids, size \\ 10) do
    target_evidences = from(q in SkillEvidence, where: q.user_id in ^user_ids)
    target_evidence_ids = from(q in target_evidences, select: q.id)

    latest_post =
      from(
        sep in SkillEvidencePost,
        where: sep.skill_evidence_id in subquery(target_evidence_ids),
        group_by: sep.skill_evidence_id,
        select: %{
          skill_evidence_id: sep.skill_evidence_id,
          latest_post_time: max(sep.inserted_at)
        }
      )

    from(
      se in subquery(target_evidences),
      join: latest_sep in subquery(latest_post),
      on: se.id == latest_sep.skill_evidence_id,
      order_by: {:desc, latest_sep.latest_post_time},
      limit: ^size
    )
    |> Repo.all()
  end

  @doc """
  Gets a single skill_evidence.

  Raises `Ecto.NoResultsError` if the Skill evidence does not exist.

  ## Examples

      iex> get_skill_evidence!(123)
      %SkillEvidence{}

      iex> get_skill_evidence!(456)
      ** (Ecto.NoResultsError)

  """
  def get_skill_evidence!(id), do: Repo.get!(SkillEvidence, id)

  @doc """
  Gets a single skill_evidence by condition
  """
  def get_skill_evidence_by(condition) do
    Repo.get_by(SkillEvidence, condition)
  end

  @doc """
  Creates a skill_evidence.

  ## Examples

      iex> create_skill_evidence(%{field: value})
      {:ok, %SkillEvidence{}}

      iex> create_skill_evidence(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_skill_evidence(attrs \\ %{}) do
    %SkillEvidence{}
    |> SkillEvidence.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a skill_evidence.

  ## Examples

      iex> update_skill_evidence(skill_evidence, %{field: new_value})
      {:ok, %SkillEvidence{}}

      iex> update_skill_evidence(skill_evidence, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_skill_evidence(%SkillEvidence{} = skill_evidence, attrs) do
    skill_evidence
    |> SkillEvidence.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a skill_evidence.

  ## Examples

      iex> delete_skill_evidence(skill_evidence)
      {:ok, %SkillEvidence{}}

      iex> delete_skill_evidence(skill_evidence)
      {:error, %Ecto.Changeset{}}

  """
  def delete_skill_evidence(%SkillEvidence{} = skill_evidence) do
    Repo.delete(skill_evidence)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking skill_evidence changes.

  ## Examples

      iex> change_skill_evidence(skill_evidence)
      %Ecto.Changeset{data: %SkillEvidence{}}

  """
  def change_skill_evidence(%SkillEvidence{} = skill_evidence, attrs \\ %{}) do
    SkillEvidence.changeset(skill_evidence, attrs)
  end

  @doc """
  Returns the list of skill_evidence_posts.

  ## Examples

      iex> list_skill_evidence_posts()
      [%SkillEvidencePost{}, ...]

  """
  def list_skill_evidence_posts(query \\ SkillEvidencePost) do
    query
    |> Repo.all()
  end

  def list_skill_evidence_posts_from_skill_evidence(skill_evidence) do
    from(
      sep in Ecto.assoc(skill_evidence, :skill_evidence_posts),
      order_by: sep.inserted_at,
      join: u in assoc(sep, :user),
      join: up in assoc(u, :user_profile),
      preload: [user: {u, [user_profile: up]}]
    )
    |> list_skill_evidence_posts()
  end

  @doc """
  Gets a single skill_evidence_post.

  Raises `Ecto.NoResultsError` if the Skill evidence post does not exist.

  ## Examples

      iex> get_skill_evidence_post!(123)
      %SkillEvidencePost{}

      iex> get_skill_evidence_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_skill_evidence_post!(id), do: Repo.get!(SkillEvidencePost, id)

  def get_skill_evidence_post_by!(condition) do
    Repo.get_by!(SkillEvidencePost, condition)
  end

  @doc """
  Creates a skill_evidence_post.

  ## Examples

      iex> create_skill_evidence_post(%{field: value})
      {:ok, %SkillEvidencePost{}}

      iex> create_skill_evidence_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_skill_evidence_post(skill_evidence, user, attrs \\ %{}) do
    %SkillEvidencePost{
      skill_evidence_id: skill_evidence.id,
      user_id: user.id
    }
    |> SkillEvidencePost.changeset(attrs)
    |> Repo.insert()
  end

  # image_names: 添付画像名リスト
  def create_skill_evidence_post(skill_evidence, user, attrs, image_names) do
    image_paths = Enum.map(image_names, &build_image_path/1)
    attrs = Map.put(attrs, "image_paths", image_paths)
    create_skill_evidence_post(skill_evidence, user, attrs)
  end

  @doc """
  Deletes a skill_evidence_post.

  ## Examples

      iex> delete_skill_evidence_post(skill_evidence_post)
      {:ok, %SkillEvidencePost{}}

      iex> delete_skill_evidence_post(skill_evidence_post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_skill_evidence_post(%SkillEvidencePost{} = skill_evidence_post) do
    # 削除は添付画像を含む。先に存在確認を実施
    image_paths =
      (skill_evidence_post.image_paths || [])
      |> Enum.filter(fn storage_path ->
        case Storage.get(storage_path) do
          {:ok, _} -> true
          _ -> false
        end
      end)

    Ecto.Multi.new()
    |> Ecto.Multi.delete(:delete, skill_evidence_post)
    |> Ecto.Multi.run(:delete_images, fn _repo, _data ->
      Enum.each(image_paths, &Storage.delete!/1)
      {:ok, :deleted}
    end)
    |> Repo.transaction()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking skill_evidence_post changes.

  ## Examples

      iex> change_skill_evidence_post(skill_evidence_post)
      %Ecto.Changeset{data: %SkillEvidencePost{}}

  """
  def change_skill_evidence_post(%SkillEvidencePost{} = skill_evidence_post, attrs \\ %{}) do
    SkillEvidencePost.changeset(skill_evidence_post, attrs)
  end

  # Build image_path by file_name.
  defp build_image_path(file_name) do
    "skill_evidence_posts/image_#{Ecto.UUID.generate()}" <> Path.extname(file_name)
  end

  @doc """
  ヘルプ処理
  通知対象は、チームメンバー、支援元チームメンバー、支援先チームメンバー
  """
  def help(skill_evidence, user) do
    skill_breadcrumb = get_skill_breadcrumb(%{id: skill_evidence.skill_id})
    timestamp = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    base_attrs = %{
      from_user_id: user.id,
      message: "#{user.name}さんから「#{skill_breadcrumb}」のヘルプが届きました",
      url: "/notifications/evidences/#{skill_evidence.id}",
      inserted_at: timestamp,
      updated_at: timestamp
    }

    Notifications.list_related_user_ids(user)
    |> Enum.map(fn user_id ->
      Map.merge(base_attrs, %{
        id: Ecto.ULID.generate(),
        to_user_id: user_id
      })
    end)
    |> then(&Notifications.create_notifications("evidence", &1))
  end

  @doc """
  返信受け取り処理
  エビデンスの所有者に対する通知を生成
  """
  def receive_post(skill_evidence, user) do
    skill_breadcrumb = get_skill_breadcrumb(%{id: skill_evidence.skill_id})

    Notifications.create_notification("evidence", %{
      from_user_id: user.id,
      to_user_id: skill_evidence.user_id,
      message: "#{user.name}さんから「#{skill_breadcrumb}」にメッセージが届きました",
      url: "/notifications/evidences/#{skill_evidence.id}"
    })
  end

  @doc """
  スキル階層名を返す
  スキルユニット名 > スキルカテゴリ名 > スキル名

  ## Examples

      iex> get_skill_breadcrumb(skill)
      "Elixir本体 > 基本 > 基本型／演算子／パイプ"
  """
  def get_skill_breadcrumb(%{id: skill_id}) do
    from(
      s in SkillUnits.Skill,
      where: s.id == ^skill_id,
      join: sc in assoc(s, :skill_category),
      join: su in assoc(sc, :skill_unit),
      select: {su.name, sc.name, s.name}
    )
    |> Repo.one()
    |> Tuple.to_list()
    |> Enum.join(" > ")
  end

  @doc """
  学習メモに書き込めるかどうかを返す
  NOTE: 現在は匿名書き込み不可。匿名書き込みを許可に変更するときは、通知メッセージ内のnameに注意
  """
  def can_write_skill_evidence?(skill_evidence, user) do
    skill_evidence.user_id == user.id ||
      Teams.joined_teams_or_supportee_teams_or_supporter_teams_by_user_id!(
        skill_evidence.user_id,
        user.id
      )
  rescue
    Bright.Exceptions.ForbiddenResourceError -> false
  end

  @doc """
  学習メモ投稿を削除できるかどうかを返す
  """
  def can_delete_skill_evidence_post?(skill_evidence_post, skill_evidence, user) do
    skill_evidence_post.user_id == user.id ||
      skill_evidence.user_id == user.id
  end

  @doc """
  学習メモ登録率(%)を返す。
  完全達成時に100%と表示し99.5%などでは99%と表示するため切り捨てている。
  """
  def calc_filled_percentage(value, size) do
    Percentage.calc_floor_percentage(value, size)
  end

  @doc """
  指定sizeでtruncateした文字列を返す
  """
  def truncate_post_content(str, size) do
    String.at(str, size)
    |> if do
      String.slice(str, 0, size - 3) <> "..."
    else
      str
    end
  end
end

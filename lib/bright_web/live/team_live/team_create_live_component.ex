defmodule BrightWeb.TeamCreateLiveComponent do
  @moduledoc """
  チーム作成モーダルのLiveComponent
  """
  use BrightWeb, :live_component

  import BrightWeb.ProfileComponents
  alias Bright.Accounts
  alias Bright.Teams
  alias Bright.Teams.Team

  @impl true
  def update(assigns, socket) do
    team_changeset = Team.changeset(%Team{}, %{})

    socket =
      socket
      |> assign(:search_word, nil)
      |> assign(:search_word_error, nil)
      |> assign_team_form(team_changeset)

    socket =
      if !Map.has_key?(assigns, :team) do
        socket
        |> assign(assigns)
        |> assign(:team, %Team{})
        |> assign(:name, nil)
      end

    {:ok, socket}
  end

  @impl true
  def handle_event("change_add_user", %{"search_word" => search_word}, socket) do
    socket =
      socket
      |> assign(:search_word, search_word)

    {:noreply, socket}
  end

  @impl true
  def handle_event("add_user", _params, socket) do
    search_word = socket.assigns.search_word

    selected_users = socket.assigns.users

    user =
      search_word
      |> Accounts.get_user_by_name_or_email()

    socket =
      cond do
        user == nil ->
          socket
          # TODO Gettext未対応
          |> assign(search_word_error: "該当のユーザーが見つかりませんでした")

        user.id == socket.assigns.current_user.id ->
          socket
          # TODO Gettext未対応
          |> assign(search_word_error: "チーム作成者は自動的に管理者として追加されます")

        true ->
          if id_duplidated_user?(user, selected_users) do
            socket
            # TODO Gettext未対応
            |> assign(search_word_error: "対象のユーザーは既に追加されています")
          else
            # メンバーユーザー一時リストに追加
            added_users =
              [user | selected_users]
              |> Enum.reverse()

            socket
            |> assign(:users, added_users)
            |> assign(:search_word, nil)
            |> assign(:search_word_error, nil)
          end
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate_team", %{"name" => name}, socket) do
    changeset =
      socket.assigns.team
      |> Team.registration_changeset(%{name: name})
      |> Map.put(:action, :validate)

    socket =
      socket
      |> assign_team_form(changeset)
      |> assign(:name, name)

    {:noreply, socket}
  end

  def handle_event("remove_user", %{"id" => id}, socket) do
    current_users = socket.assigns.users

    # メンバーユーザー一時リストから削除
    removed_users =
      current_users
      |> Enum.reject(fn x -> x.id == id end)

    {:noreply, assign(socket, :users, removed_users)}
  end

  @impl true
  def handle_event("create_team", %{"name" => team_name}, socket) do
    member_users = socket.assigns.users
    admin_user = socket.assigns.current_user

    case Teams.create_team_multi(team_name, admin_user, member_users) do
      {:ok, team, member_user_attrs} ->
        # 全メンバーのuserを一気にpreloadしたいのでteamを再取得
        preloaded_team = Teams.get_team_with_member_users!(team.id)

        # 招待したメンバー全員に招待メールを送信する。
        send_invitation_mail(preloaded_team, admin_user, member_user_attrs)

        # メール送信の成否に関わらず正常終了とする
        # TODO メール送信エラーを運用上検知する必要がないか?

        {:noreply,
         socket
         |> put_flash(:info, "チームを登録しました")
         # TODO チーム作成後は、作成したチームのチームスキル分析に遷移した方がよいか？
         |> redirect(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset)}
    end
  end

  defp send_invitation_mail(preloaded_team, admin_user, member_user_attrs) do
    _results =
      preloaded_team.member_users
      |> Enum.map(fn member_user ->
        if !member_user.is_admin do
          # 管理者以外に招待メールを送信する
          # member_attrのリストから該当ユーザーのbase64_encode済tokenを取得してメールに添付
          member_user_attr =
            member_user_attrs
            |> Enum.find(fn member_user_attr ->
              member_user_attr.user_id == member_user.user_id
            end)

          Teams.deliver_invitation_email_instructions(
            admin_user,
            member_user.user,
            preloaded_team,
            member_user_attr.base64_encoded_token,
            &url(~p"/teams/invitation_confirm/#{&1}")
          )
        end
      end)
  end

  defp assign_team_form(socket, %Ecto.Changeset{} = changeset) do
    team_form = to_form(changeset)

    socket =
      socket
      |> assign(:team_form, team_form)

    socket
  end

  defp id_duplidated_user?(user, users) do
    duplidate_user =
      users
      |> Enum.find(fn u ->
        user.id == u.id
      end)

    if duplidate_user == nil do
      false
    else
      true
    end
  end
end

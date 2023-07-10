defmodule BrightWeb.MypageLive.Index do
  alias Faker.Vehicle.En
  alias Bright.UserProfiles
  use BrightWeb, :live_view
  import BrightWeb.ProfileComponents
  import BrightWeb.SkillScoreComponents
  import BrightWeb.ContactCardComponents
  import BrightWeb.SkillCardComponents
  import BrightWeb.CommunicationCardComponents
  import BrightWeb.IntriguingCardComponents
  alias Bright.UserProfiles
  alias Bright.Notifications

  @impl true
  def mount(_params, _session, socket) do
    profile = UserProfiles.get_user_profile_by_name(socket.assigns.current_user.name)

    recruitment_coordination =
      Notifications.list_notification_by_type(
        socket.assigns.current_user.id,
        "recruitment_coordination"
      )
      |> Enum.map(&conveart_card/1)

    {:ok,
     socket
     |> assign(:page_title, "Listing Mypages")
     |> assign(:profile, profile || dummy_profile())
     |> assign(:recruitment_coordination, recruitment_coordination)}
  end

  @spec conveart_card(map) :: any
  def conveart_card(row) do
    row
    |> Map.take([:icon_type, :message, :inserted_at])
    # TODO 「何時間前」の計算を入れること
    |> Map.delete(:inserted_at)
    # TODO 「何時間前」の計算後の処理を書くこと
    |> Map.merge(%{time: 1, highlight: true})
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Mypages")
    |> assign(:mypage, nil)
  end

  # 正式な処理が入るまでダミーデータを表示
  def dummy_profile do
    %{
      user: %{name: "ダミー名前"},
      title: "ダミー称号",
      detail: "ダミー詳細",
      icon_file_path: "",
      twitter_url: "",
      github_url: "",
      facebook_url: ""
    }
  end
end

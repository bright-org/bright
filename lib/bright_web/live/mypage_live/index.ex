defmodule BrightWeb.MypageLive.Index do
  alias Bright.UserProfiles
  use BrightWeb, :live_view
  import BrightWeb.ProfileComponents
  import BrightWeb.SkillScoreComponents
  import BrightWeb.ContactCardComponents
  import BrightWeb.SkillCardComponents
  import BrightWeb.CommunicationCardComponents
  import BrightWeb.IntriguingCardComponents
  alias Bright.UserProfiles

  @impl true
  def mount(_params, _session, socket) do
    profile = UserProfiles.get_user_profile_by_name(socket.assigns.current_user.name)

    {:ok,
     socket
     |> assign(:page_title, "Listing Mypages")
     |> assign(:profile, profile || dummy_progiole())}
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

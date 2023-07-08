defmodule BrightWeb.MypageLive.Index do
  alias Bright.UserProfiles
  alias Bright.UserProfileFactory
  alias Hex.API.User
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
     |> assign(:profile, profile)}
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
end

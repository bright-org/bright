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
  alias Bright.Notifications

  @impl true
  def mount(_params, _session, socket) do
    profile = UserProfiles.get_user_profile_by_name(socket.assigns.current_user.name)

    contact_datas =
      Notifications.list_notification_by_type(
        socket.assigns.current_user.id,
        "recruitment_coordination"
      )
      |> Enum.map(&convert_to_card_item/1)

    {:ok,
     socket
     |> assign(:page_title, "Listing Mypages")
     |> assign(:profile, profile)
     |> assign(:contact_datas, contact_datas)}
  end

  def convert_to_card_item(notification) do
    notification
    # TODO 「何時間前」の計算を入れること
    |> Map.delete(:inserted_at)
    # TODO 「何時間前」の計算後の処理を書くこと
    |> Map.merge(%{time: 1, highlight: true})
    |> Map.take([:icon_type, :message, :time, :highlight, :inserted_at])
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

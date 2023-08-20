defmodule BrightWeb.UserSettingsLive.SnsSettingComponent do
  use BrightWeb, :live_component

  alias Bright.Repo
  alias Bright.Accounts.User
  alias Bright.Accounts.UserSocialAuth

  @impl true
  def render(assigns) do
    ~H"""
    <li class="block">
      <div class="flex flex-col mt-8">
        <div id="user_settings_sns_linked_provider" class="flex items-center mb-4 text-left" :for={linked_user_social_auth <- @linked_user_social_auths}>
          <div class="w-full">
            <BrightWeb.UserAuthComponents.social_auth_button method="delete" href={~p"/auth/#{linked_user_social_auth.provider}"} variant={to_string(linked_user_social_auth.provider)}>
              <%= UserSocialAuth.provider_name(linked_user_social_auth.provider) %>と連携解除する
            </BrightWeb.UserAuthComponents.social_auth_button>
            <span class="ml-4"><%= linked_user_social_auth.display_name %>で連携中</span>
          </div>
        </div>
        <div id="user_settings_sns_unlinked_provider" class="flex items-center mb-4 text-left" :for={unlink_provider <- @unlink_providers}>
          <div class="w-full">
            <BrightWeb.UserAuthComponents.social_auth_button href={if unlink_provider in not_implemented_providers(), do: "#", else: ~p"/auth/#{unlink_provider}"} variant={to_string(unlink_provider)}>
              <%= UserSocialAuth.provider_name(unlink_provider) %>と連携する
            </BrightWeb.UserAuthComponents.social_auth_button>
          </div>
        </div>
      </div>
    </li>
    """
  end

  @impl true
  def update(assigns, socket) do
    %User{user_social_auths: user_social_auths} =
      assigns.user
      |> Repo.preload(:user_social_auths)

    {:ok,
     socket
     |> assign(
       linked_user_social_auths: user_social_auths,
       unlink_providers: unlink_providers(user_social_auths)
     )}
  end

  defp unlink_providers(user_social_auths) do
    linked_providers = user_social_auths |> Enum.map(& &1.provider)

    UserSocialAuth.providers() |> Enum.reject(&(&1 in linked_providers))
  end

  # github, facebook, twitter 連携は未実装
  defp not_implemented_providers, do: ~w(github facebook twitter)a
end

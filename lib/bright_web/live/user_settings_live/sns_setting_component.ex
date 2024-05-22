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
        <div
          id={if provider in linked_providers(@linked_user_social_auths), do: "user_settings_sns_linked_provider", else: "user_settings_sns_unlinked_provider_#{index}"}
          class="flex items-center mb-4 text-left"
          :for={{provider, index} <- Enum.with_index(UserSocialAuth.providers(), 1)}
        >
          <%= if provider in linked_providers(@linked_user_social_auths) do %>
            <div class="w-full">
              <BrightWeb.UserAuthComponents.social_auth_button method="delete" href={~p"/auth/#{provider}"} variant={to_string(provider)}>
                <%= UserSocialAuth.provider_name(provider) %>と連携解除する
              </BrightWeb.UserAuthComponents.social_auth_button>
              <span class="ml-4"><%= user_social_auth_by_provider(@linked_user_social_auths, provider).display_name %>で連携中</span>
            </div>
          <% else %>
            <div class="w-full">
              <BrightWeb.UserAuthComponents.social_auth_button href={if provider in not_implemented_providers(), do: "#", else: ~p"/auth/#{provider}"} variant={to_string(provider)}>
                <%= UserSocialAuth.provider_name(provider) %>と連携する
              </BrightWeb.UserAuthComponents.social_auth_button>
            </div>
          <% end %>
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
     |> assign(linked_user_social_auths: user_social_auths)}
  end

  defp linked_providers(user_social_auths) do
    user_social_auths |> Enum.map(& &1.provider)
  end

  defp user_social_auth_by_provider(user_social_auths, provider) do
    user_social_auths |> Enum.find(&(&1.provider == provider))
  end

  # facebook, twitter 連携は未実装
  defp not_implemented_providers, do: ~w(facebook twitter)a
end

defmodule BrightWeb.Openid.WellKnownController do
  use BrightWeb, :controller

  alias Boruta.Oauth.Client

  def configuration(conn, _params) do
    # See https://github.com/malach-it/boruta-server/blob/371498a996888c34e9d58be39b9720304f5999fe/apps/boruta_web/lib/boruta_web/views/oauth_view.ex#L48-L87
    issuer = Boruta.Config.issuer()
    endpoint_base = String.replace(issuer, "localhost", "host.docker.internal")

    configuration = %{
      "issuer" => issuer,
      "authorization_endpoint" => issuer <> ~p"/openid/authorize",
      "token_endpoint" => endpoint_base <> ~p"/oauth/token",
      "userinfo_endpoint" => endpoint_base <> ~p"/openid/userinfo",
      "jwks_uri" => endpoint_base <> ~p"/openid/jwks",
      "grant_types_supported" => [
        "client_credentials",
        "password",
        "implicit",
        "authorization_code",
        "refresh_token"
      ],
      "response_types_supported" => [
        "code",
        "token",
        "id_token",
        "code token",
        "code id_token",
        "token id_token",
        "code id_token token"
      ],
      "response_modes_supported" => ["query", "fragment"],
      "subject_types_supported" => ["public"],
      "token_endpoint_auth_methods_supported" => [
        "client_secret_basic",
        "client_secret_post",
        "client_secret_jwt",
        "private_key_jwt"
      ],
      "request_object_signing_alg_values_supported" => Client.Crypto.signature_algorithms(),
      "id_token_signing_alg_values_supported" => Client.Crypto.signature_algorithms(),
      "userinfo_signing_alg_values_supported" => Client.Crypto.signature_algorithms()
    }

    json(conn, configuration)
  end
end

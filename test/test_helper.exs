{:ok, _} = Application.ensure_all_started(:ex_machina)
ExUnit.start()
Faker.start()
Ecto.Adapters.SQL.Sandbox.mode(Bright.Repo, :manual)

Mox.defmock(Boruta.OauthMock, for: Boruta.OauthModule)
Mox.defmock(Boruta.OpenidMock, for: Boruta.OpenidModule)

# Setup fake gcs test bucket
GoogleApi.Storage.V1.Api.Buckets.storage_buckets_insert(
  GoogleApi.Storage.V1.Connection.new(),
  # project name
  "my_test",
  body: %GoogleApi.Storage.V1.Model.Bucket{
    name: Application.fetch_env!(:bright, :google_api_storage) |> Keyword.fetch!(:bucket_name)
  }
)

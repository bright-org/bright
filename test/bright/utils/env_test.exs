defmodule Bright.Utils.EnvTest do
  use ExUnit.Case, async: true
  use ExUnit.Parameterized
  import Mock

  alias Bright.Utils.Env

  describe "prod?/0" do
    test_with_params "returns boolean by environment variable", fn environment_name, expected ->
      with_mock(System, [:passthrough],
        get_env: fn "SENTRY_ENVIRONMENT_NAME" -> environment_name end
      ) do
        assert Env.prod?() == expected
      end
    end do
      [
        {nil, false},
        {"dev", false},
        {"stg", false},
        {"prod", true}
      ]
    end
  end
end

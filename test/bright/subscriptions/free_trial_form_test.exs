defmodule Bright.Subscriptions.FreeTrialFormTest do
  use ExUnit.Case, async: true
  use ExUnit.Parameterized

  alias Bright.Subscriptions.FreeTrialForm

  describe "phone_number validation" do
    test_with_params "check format",
                     fn value, expected ->
                       %{errors: errors} =
                         FreeTrialForm.changeset(%FreeTrialForm{}, %{phone_number: value})

                       if expected == :ng do
                         assert :phone_number in Keyword.keys(errors)
                       else
                         refute :phone_number in Keyword.keys(errors)
                       end
                     end do
      [
        {"03-5321-1111", :ok},
        {"12345678901", :ok},
        {"+1-90-8561-2341", :ok},
        {"123456789", :ok},
        {"12345678", :ng},
        {"あいうえお", :ng},
        {"+1 90-8561-2341", :ng},
        {"0a-5321-1111", :ng},
        {"03-532a-1111", :ng},
        {"03-5321-111a", :ng},
        {"0あ-5321-1111", :ng},
        {"０3-5321-1111", :ng}
      ]
    end
  end
end

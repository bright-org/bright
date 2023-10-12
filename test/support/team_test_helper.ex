defmodule Bright.TeamTestHelper do
  @moduledoc """
  Team Test helpers.
  """

  alias Bright.Teams

  @doc """
    チーム招待の承認を一括で行う
  """
  def cofirm_invitation(team_member_user_attrs) do
    team_member_user_attrs
    |> Enum.each(fn team_member_user_attr ->
      {:ok, joined_team_member_user} =
        Teams.get_invitation_token(team_member_user_attr.base64_encoded_token)

      {:ok, _joined_confirmed_team_member_user} =
        Teams.confirm_invitation(joined_team_member_user)
    end)
  end
end

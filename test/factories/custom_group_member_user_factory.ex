defmodule Bright.CustomGroupMemberUserFactory do
  @moduledoc """
  Factory for Bright.CustomGroups.CustomGroupMemberUser
  """

  defmacro __using__(_opts) do
    quote do
      def custom_group_member_user_factory do
        %Bright.CustomGroups.CustomGroupMemberUser{}
      end
    end
  end
end

defmodule Bright.RecruitmentStockUserFactory do
  @moduledoc """
  Factory for Bright.RecruitmentStockUsers.RecruitmentStockUser
  """

  defmacro __using__(_opts) do
    quote do
      def recruitment_stock_user_factory do
        %Bright.RecruitmentStockUsers.RecruitmentStockUser{
          recruiter: build(:user),
          user: build(:user)
        }
      end
    end
  end
end

defmodule BrightWeb.Layouts do
  @moduledoc false

  use BrightWeb, :html
  import BrightWeb.LayoutComponents

  embed_templates "layouts/*"

  def get_user_id(assigns) do
    user = Map.get(assigns, :current_user)

    if user == nil do
      ""
    else
      user.id
    end
  end
end

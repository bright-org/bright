defmodule BrightWeb.Layouts do
  @moduledoc false

  use BrightWeb, :html
  import BrightWeb.MenuComponents
  import BrightWeb.LayoutComponents

  embed_templates "layouts/*"
end

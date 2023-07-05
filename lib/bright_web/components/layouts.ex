defmodule BrightWeb.Layouts do
  @moduledoc false

  use BrightWeb, :html
  import BrightWeb.MenuComponents

  embed_templates "layouts/*"
end

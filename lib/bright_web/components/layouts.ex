defmodule BrightWeb.Layouts do
  @moduledoc false

  use BrightWeb, :html
  import BrightWeb.MenuComponents
  import BrightWeb.HeadComponents

  embed_templates "layouts/*"
end

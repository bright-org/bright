defmodule BrightWeb.ErrorHTML do
  use BrightWeb, :html
  import BrightWeb.LayoutComponents
  import BrightWeb.BrightButtonComponents, only: [contact_customer_success_button: 1]
  import BrightWeb.Layouts, only: [get_user_id: 1]

  # If you want to customize your error pages,
  # uncomment the embed_templates/1 call below
  # and add pages to the error directory:
  #
  #   * lib/bright_web/controllers/error_html/404.html.heex
  #   * lib/bright_web/controllers/error_html/500.html.heex
  #
  embed_templates "error_html/*"

  # The default is to render a plain text page based on
  # the template name. For example, "404.html" becomes
  # "Not Found".
  def render(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end

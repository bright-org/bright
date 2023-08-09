defmodule BrightWeb.ErrorHTMLTest do
  use BrightWeb.ConnCase, async: true

  # Bring render_to_string/4 for testing custom views
  import Phoenix.Template

  test "renders 404.html" do
    assert render_to_string(BrightWeb.ErrorHTML, "404", "html", []) =~ "アクセス先が見つかりませんでした。"
  end

  test "renders 500.html" do
    assert render_to_string(BrightWeb.ErrorHTML, "500", "html", []) =~ "アクセス先を表示できませんでした。"
  end
end

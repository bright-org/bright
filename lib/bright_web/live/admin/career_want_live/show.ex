defmodule BrightWeb.Admin.CareerWantLive.Show do
  use BrightWeb, :live_view

  alias Bright.{CareerWants, Repo}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    career_want =
      CareerWants.get_career_want!(id)
      |> Repo.preload(skill_panels: :career_fields)
      |> then(
        &Map.put(
          &1,
          :skill_panels,
          Enum.group_by(&1.skill_panels, fn s -> List.first(s.career_fields).name_ja end)
        )
      )

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:career_want, career_want)}
  end

  defp page_title(:show), do: "Show Career want"
  defp page_title(:edit), do: "Edit Career want"
end

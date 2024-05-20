defmodule BrightWeb.Admin.InterviewLive.FormComponent do
  use BrightWeb, :live_component

  alias Bright.Recruits

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage interview records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="interview-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:recruiter_user_id]} type="text" label="Recruiter User Id" />
        <.input field={@form[:candidates_user_id]} type="text" label="Candidates User Id" />
        <.input field={@form[:skill_params]} type="text" label="Skill params" />
        <.input field={@form[:comment]} type="text" label="Comment" />
        <.input
          field={@form[:status]}
          type="select"
          label="Status"
          options={Ecto.Enum.mappings(Recruits.Interview, :status)}
        />
        <:actions>
          <.button phx-disable-with="Saving...">Save Interview</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{interview: interview} = assigns, socket) do
    changeset = Recruits.change_interview(interview)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"interview" => interview_params}, socket) do
    changeset =
      socket.assigns.interview
      |> Recruits.change_interview(interview_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"interview" => interview_params}, socket) do
    save_interview(socket, socket.assigns.action, interview_params)
  end

  defp save_interview(socket, :edit, interview_params) do
    case Recruits.update_interview(socket.assigns.interview, interview_params) do
      {:ok, interview} ->
        notify_parent({:saved, interview})

        {:noreply,
         socket
         |> put_flash(:info, "Interview updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_interview(socket, :new, interview_params) do
    case Recruits.create_interview(interview_params) do
      {:ok, interview} ->
        notify_parent({:saved, interview})

        {:noreply,
         socket
         |> put_flash(:info, "Interview created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end

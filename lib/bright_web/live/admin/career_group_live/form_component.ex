defmodule BrightWeb.Admin.CareerGroupLive.FormComponent do
  use BrightWeb, :live_component

  alias Bright.CareerGroups
  alias Bright.CareerFields
  alias Bright.Accounts.User

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage career_group records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="career_group-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:type]} type="select" label="Type" options={Ecto.Enum.values(User, :type)} />
        <.input field={@form[:position]} type="number" label="Position" />
        <.label>CareerFields</.label>
        <.inputs_for :let={c} field={@form[:career_group_career_fields]}>
          <input type="hidden" name="career_group[career_group_career_fields_sort][]" value={c.index} />
          <.input
            field={c[:career_field_id]}
            type="select"
            label="CareerField"
            prompt="CareerFieldを選択してください"
            options={@career_field_options}
          />
          <label class="cursor-pointer">
            <input
              type="checkbox"
              name="career_group[career_group_career_fields_drop][]"
              value={c.index}
              class="hidden"
            /> delete
          </label>
        </.inputs_for>
        <label class="block cursor-pointer">
          <input type="checkbox" name="career_group[career_group_career_fields_sort][]" class="hidden" />
          add career_field
        </label>

        <:actions>
          <.button phx-disable-with="Saving...">Save Career group</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{career_group: career_group} = assigns, socket) do
    changeset =
      career_group
      |> preload_assoc()
      |> CareerGroups.change_career_group()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:career_field_options, career_field_options())
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"career_group" => career_group_params}, socket) do
    changeset =
      socket.assigns.career_group
      |> preload_assoc()
      |> CareerGroups.change_career_group(career_group_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"career_group" => career_group_params}, socket) do
    save_career_group(socket, socket.assigns.action, career_group_params)
  end

  defp save_career_group(socket, :edit, career_group_params) do
    career_group = preload_assoc(socket.assigns.career_group)

    case CareerGroups.update_career_group(career_group, career_group_params) do
      {:ok, career_group} ->
        notify_parent({:saved, career_group})

        {:noreply,
         socket
         |> put_flash(:info, "Career group updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_career_group(socket, :new, career_group_params) do
    case CareerGroups.create_career_group(career_group_params) do
      {:ok, career_group} ->
        notify_parent({:saved, preload_assoc(career_group)})

        {:noreply,
         socket
         |> put_flash(:info, "Career group created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp career_field_options() do
    CareerFields.list_career_fields()
    |> Enum.map(&{&1.name_en, &1.id})
  end

  defp preload_assoc(career_group) do
    Bright.Repo.preload(career_group, [:career_fields, :career_group_career_fields])
  end
end

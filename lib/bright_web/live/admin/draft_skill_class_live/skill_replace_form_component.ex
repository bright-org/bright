defmodule BrightWeb.Admin.DraftSkillClassLive.SkillReplaceFormComponent do
  use BrightWeb, :live_component

  alias Bright.DraftSkillUnits

  def render(assigns) do
    ~H"""
    <div id={@id}>
      <.header class="my-2">
        <p><%= @skill.name %></p>
        <:subtitle>カテゴリー移動</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="skill-replace-form"
        phx-target={@myself}
        phx-submit="save"
      >
        <.input field={@form[:draft_skill_category_id]} value={@skill_category_id} type="hidden" />

        <ul>
          <li :for={category <- @skill_categories} class="my-2">
            <%= if category.id == @skill_category_id do %>
              <button type="button" class="border rounded-lg bg-zinc-400">
                <span class="p-2"><%= category.name %></span>
              </button>
            <% else %>
              <button type="button" class="border rounded-lg bg-zinc-50 hover:bg-zinc-400" phx-click="select" phx-target={@myself} phx-value-id={category.id}>
                <span class="p-2"><%= category.name %></span>
              </button>
            <% end %>
          </li>
        </ul>

        <p>
          スキルクラス外への移動の場合は下記から選択してください
          <br />
          スキルパネル - スキルクラス - スキルユニット - スキルカテゴリー
          <br />
          Coming soon
        </p>

        <:actions>
          <.button phx-disable-with="Saving...">保存</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def update(%{skill: skill} = assigns, socket) do
    changeset = DraftSkillUnits.change_draft_skill(skill)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:skill_category_id, skill.draft_skill_category_id)
     |> assign_form(changeset)}
  end

  def handle_event("select", %{"id" => id}, socket) do
    {:noreply, assign(socket, :skill_category_id, id)}
  end

  def handle_event("save", %{"draft_skill" => skill_params}, socket) do
    skill = socket.assigns.skill
    skill_category = DraftSkillUnits.get_draft_skill_category!(skill_params["draft_skill_category_id"])

    # 末尾追加とする
    position =
      DraftSkillUnits.get_max_position(skill_category, :draft_skills)
      |> Kernel.+(1)

    skill_params = Map.put(skill_params, "position", position)

    case DraftSkillUnits.update_draft_skill(skill, skill_params) do
      {:ok, _skill} ->
        {:noreply,
         socket
         |> put_flash(:info, "スキルを移動しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end

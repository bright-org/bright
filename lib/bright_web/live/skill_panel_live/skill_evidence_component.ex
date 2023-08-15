defmodule BrightWeb.SkillPanelLive.SkillEvidenceComponent do
  use BrightWeb, :live_component

  alias Bright.SkillEvidences
  alias Bright.SkillScores

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id}>
      <.header> <%= @skill.name %> </.header>

      <div
        id="skill_evidence_posts"
        phx-update="stream"
      >
        <div
          :for={{id, post} <- @streams.skill_evidence_posts}
          id={id}
        >
          <div class="flex justify-between my-2">
            <%= Phoenix.HTML.Format.text_to_html post.content %>
            <div class="cursor-pointer" phx-click="delete" phx-target={@myself} phx-value-id={post.id}>
              Ｘ削除
            </div>
          </div>
        </div>
      </div>

      <.simple_form
        for={@form}
        id="skill_evidence_post-form"
        phx-target={@myself}
        phx-submit="save"
      >
        <.input
          field={@form[:content]}
          type="textarea"
          label="エビデンスを入力" />
        <:actions>
          <.button phx-disable-with="送信中...">メモを書き込む</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    skill_evidence_posts =
      assigns.skill_evidence
      |> Ecto.assoc(:skill_evidence_posts)
      |> SkillEvidences.list_skill_evidence_posts()

    {:ok,
     socket
     |> assign(assigns)
     |> stream(:skill_evidence_posts, skill_evidence_posts)
     |> assign_form()}
  end

  @impl true
  def handle_event("save", %{"skill_evidence_post" => params}, socket) do
    SkillEvidences.create_skill_evidence_post(
      socket.assigns.skill_evidence,
      socket.assigns.user,
      params
    )
    |> case do
      {:ok, skill_evidence_post} ->
        if post_by_myself(socket.assigns.user, socket.assigns.skill_evidence) do
          SkillScores.update_skill_score_evidence_filled(
            socket.assigns.user,
            socket.assigns.skill
          )
        end

        {:noreply,
         socket
         |> stream_insert(:skill_evidence_posts, skill_evidence_post, at: -1)
         |> assign_form()}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => skill_evidence_post_id}, socket) do
    SkillEvidences.get_skill_evidence_post!(skill_evidence_post_id)
    |> SkillEvidences.delete_skill_evidence_post()
    |> case do
      {:ok, skill_evidence_post} ->
        {:noreply,
         socket
         |> stream_delete(:skill_evidence_posts, skill_evidence_post)}

      _ ->
        {:noreply, socket}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp assign_form(socket) do
    changeset = SkillEvidences.change_skill_evidence_post(%SkillEvidences.SkillEvidencePost{})
    assign_form(socket, changeset)
  end

  defp post_by_myself(user, skill_evidence) do
    user.id == skill_evidence.user_id
  end
end

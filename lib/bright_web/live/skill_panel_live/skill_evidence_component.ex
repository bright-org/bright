defmodule BrightWeb.SkillPanelLive.SkillEvidenceComponent do
  use BrightWeb, :live_component

  alias Bright.SkillEvidences
  alias Bright.SkillScores

  @unkown_icon "/images/avatar.png"

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} class="max-h-[80vh] overflow-y-auto">
      <div class="flex justify-center items-center">
        <div class="w-full lg:w-[450px]">
          <p class="pb-2 text-base font-bold">
            <%= @skill.name %>
          </p>

          <div id="skill_evidence_posts" phx-update="stream">
            <div
              :for={{id, post} <- @streams.skill_evidence_posts}
              id={id}
              class="flex flex-wrap my-2"
            >
              <div class="w-[50px] flex justify-center flex-col items-center">
                <div class="min-h-content">
                  <img class="h-10 w-10 rounded-full" src={icon_file_path(post.user, @anonymous)} />
                </div>
                <hr class="w-[1px] bg-brightGray-200 h-full mt-2" />
              </div>

              <div class="w-[370px] pb-4">
                <div class="text-base">
                  <%= Phoenix.HTML.Format.text_to_html post.content, attributes: [class: "break-all first:mt-0 mt-3"] %>
                </div>
                <div
                  class="h-6 w-6 py-2 ml-auto cursor-pointer"
                  phx-click="delete"
                  phx-target={@myself}
                  phx-value-id={post.id}
                >
                  <span class="material-symbols-outlined text-brightGray-500 font-xs hover:opacity-50">delete</span>
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
            <div>
              <% # コメント入力 %>
              <div class="flex flex-wrap pb-2">
                <div class="w-[50px] flex justify-center flex-col items-center">
                  <img class="inline-block h-10 w-10 rounded-full" src={icon_file_path(@user, @anonymous)} />
                </div>
                <div class="w-[370px]">
                  <.input_textarea field={@form[:content]} />
                </div>
              </div>
              <hr class="pb-1 mt-0 border-brightGray-100" />
              <% # TODO: α後に実装して有効化 %>
              <div :if={false} class="flex justify-end py-2 items-center">
                <label>
                  <input
                    type="checkbox"
                    value=""
                    class="w-4 h-4 mr-3"
                  />学習を完了する
                </label>
              </div>
              <div class="flex justify-end gap-x-4 py-2">
                <% # TODO: α後に実装して有効化 %>
                <button :if={false} class="mr-auto">
                  <span class="material-icons-outlined !text-4xl">
                    add_photo_alternate
                  </span>
                </button>
                <button
                  class="text-sm font-bold px-5 py-2 rounded border bg-base text-white"
                  type="submit"
                  phx-disable-with="送信中..."
                >
                  メモを書き込む
                </button>
                <% # TODO: α後に実装して有効化 %>
                <button
                  :if={false}
                  class="text-sm font-bold px-5 py-2 rounded border bg-base text-white"
                >
                  このメモでヘルプを出す
                </button>
              </div>
            </div>
          </.simple_form>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    skill_evidence_posts =
      SkillEvidences.list_skill_evidence_posts_from_skill_evidence(assigns.skill_evidence)

    {:ok,
     socket
     |> assign(assigns)
     |> stream(:skill_evidence_posts, skill_evidence_posts)
     |> update(:user, &Bright.Repo.preload(&1, :user_profile))
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
        skill_evidence_post = Bright.Repo.preload(skill_evidence_post, user: [:user_profile])

        if post_by_myself(socket.assigns.user, socket.assigns.skill_evidence) do
          SkillScores.make_skill_score_evidence_filled(
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

  defp icon_file_path(_user, true), do: @unkown_icon

  defp icon_file_path(user, _anonymous) do
    Bright.UserProfiles.icon_url(user.user_profile.icon_file_path)
  end

  # TODO: CoreComponentとの統合検討
  attr :id, :any, default: nil
  attr :field, Phoenix.HTML.FormField

  defp input_textarea(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns =
      assigns
      |> assign(field: nil, id: assigns.id || field.id)
      |> assign(:errors, Enum.map(field.errors, &translate_error(&1)))
      |> assign_new(:name, fn -> field.name end)
      |> assign_new(:value, fn -> field.value end)

    ~H"""
    <div phx-feedback-for={@name}>
      <textarea
        id={@id}
        name={@name}
        placeholder="コメントを入力"
        class="w-full min-h-1 outline-none border-none focus:ring-0 p-2"
      ><%= Phoenix.HTML.Form.normalize_value("textarea", @value) %></textarea>
      <div>
        <.error :for={msg <- @errors}><%= msg %></.error>
      </div>
    </div>
    """
  end
end

defmodule BrightWeb.SkillPanelLive.SkillEvidenceComponent do
  use BrightWeb, :live_component

  alias Bright.SkillEvidences
  alias Bright.SkillScores
  alias Bright.UserProfiles
  alias Bright.Utils.GoogleCloud.Storage
  alias BrightWeb.BrightCoreComponents

  @help_message """
  （このメモでヘルプを出しました）
  """

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} class="max-h-[80vh] overflow-y-auto">
      <div class="flex justify-center items-center">
        <div class="w-full lg:w-[450px]">
          <p class="pb-2 text-base font-bold">
            <%= @title %>
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
                <% # 投稿内容表示 %>
                <div class="text-base">
                  <div
                    id={"timestamp-#{id}"}
                    class="flex justify-end"
                    phx-hook="LocalTime"
                    phx-update="ignore"
                    data-iso={NaiveDateTime.to_iso8601(post.inserted_at)}
                   >
                    <p class="text-sm" data-local-time="%x %H:%M"></p>
                  </div>
                  <BrightCoreComponents.text_to_html_with_link text={post.content} attributes={[class: "break-all first:mt-0 mt-3"]} />
                </div>

                <% # 画像表示 %>
                <%= case post.image_paths do %>
                  <% nil -> %>
                  <% [] -> %>
                  <% [image_path] -> %>
                    <div class="evidence-image object-cover relative mt-3 cursor-pointer">
                      <img class="imagebox" src={image_url(image_path)} />
                    </div>
                  <% image_paths -> %>
                    <div class="evidence-images gap-2 flex flex-wrap mt-3">
                      <%= for image_path <- image_paths do %>
                        <div class="object-cover relative w-[calc(50%-0.25rem)] box-border cursor-pointer">
                          <img class="imagebox" src={image_url(image_path)} />
                        </div>
                      <% end %>
                    </div>
                <% end %>

                <% # 削除ボタン %>
                <div
                  :if={deletable_user?(post, @skill_evidence, @user)}
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
            :if={@postable?}
            for={@form}
            id="skill_evidence_post-form"
            phx-target={@myself}
            phx-submit="save"
            phx-change="validate">
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

              <% # アップロード画像プレビュー %>
              <div class="mb-2">
                <.error :for={err <- upload_errors(@uploads.image)}><%= upload_error_to_string(err) %></.error>
                <.error :for={err <- @entry_errors}><%= upload_error_to_string(err) %></.error>
              </div>
              <%= if Enum.count(@uploads.image.entries) == 1 do %>
                <div class="object-cover relative mt-1 cursor-pointer">
                  <.uploading_image myself={@myself} entry={hd(@uploads.image.entries)} />
                </div>
              <% else %>
                <div class="gap-2 flex flex-wrap mt-1">
                  <%= for entry <- @uploads.image.entries do %>
                    <div class="object-cover relative w-[calc(50%-0.25rem)] box-border cursor-pointer">
                      <.uploading_image myself={@myself} entry={entry} />
                    </div>
                  <% end %>
                </div>
              <% end %>

              <% # TODO: 実装して有効化 %>
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
                <label for={@uploads.image.ref} class="block cursor-pointer mr-auto">
                  <.live_file_input upload={@uploads.image} class="hidden" />
                  <span class="material-icons-outlined !text-4xl">
                    add_photo_alternate
                  </span>
                </label>

                <button
                  class="text-sm font-bold px-5 py-2 rounded border bg-base text-white"
                  type="submit"
                  phx-disable-with="送信中..."
                  phx-click={JS.set_attribute({"value", "off"}, to: "#checkbox-help")}
                >
                  メモを書き込む
                </button>

                <button
                  :if={@me}
                  class="text-sm font-bold px-5 py-2 rounded border bg-base text-white"
                  type="submit"
                  phx-disable-with="送信中..."
                  phx-click={JS.set_attribute({"value", "on"}, to: "#checkbox-help")}
                >
                  このメモでヘルプを出す
                </button>
                <% # ヘルプを出す/出さない制御用checkbox %>
                <input type="checkbox" id="checkbox-help" class="hidden" name="help" checked={true} value="on" phx-update="ignore" />
              </div>
            </div>
          </.simple_form>
        </div>
      </div>

      <div
        id="imageboxContainer"
        class="hidden fixed top-0 left-0 z-50 w-screen h-screen bg-black/70 flex justify-center items-center"
        phx-hook="Imagebox"
        data-imagebox-container={@id}
        data-imagebox-img-target-class="imagebox">
        <img class="object-cover cursor-pointer" />
        <a class="btn-close-imagebox absolute z-50 top-6 right-8 text-white text-5xl font-bold">&times;</a>
      </div>
    </div>
    """
  end

  defp uploading_image(assigns) do
    ~H"""
    <button
      type="button"
      class="absolute top-2 right-2 flex justify-center items-center"
      phx-click="cancel_upload"
      phx-target={@myself}
      phx-value-ref={@entry.ref}>
      <span class="material-icons text-white bg-brightGray-900 rounded-full !text-sm w-5 h-5">close</span>
    </button>
    <.live_img_preview entry={@entry} class="imagebox" />
    """
  end

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> allow_upload(:image,
       accept: ~w(.jpg .jpeg .png),
       max_file_size: 5_000_000,
       max_entries: 4
     )
     |> assign(:entry_errors, [])}
  end

  @impl true
  def update(assigns, socket) do
    skill_evidence = Bright.Repo.preload(assigns.skill_evidence, :user)

    skill_evidence_posts =
      SkillEvidences.list_skill_evidence_posts_from_skill_evidence(skill_evidence)

    title = SkillEvidences.get_skill_breadcrumb(assigns.skill)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:title, title)
     |> assign(:skill_evidence, skill_evidence)
     |> stream(:skill_evidence_posts, skill_evidence_posts)
     |> update(:user, &Bright.Repo.preload(&1, :user_profile))
     |> assign(:postable?, postable_user?(skill_evidence, assigns.user))
     |> assign_form()}
  end

  @impl true
  def handle_event("validate", %{"skill_evidence_post" => params}, socket) do
    changeset =
      socket.assigns.skill_evidence_post
      |> SkillEvidences.change_skill_evidence_post(params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign_form(changeset)
     |> unassign_invalid_image_entries()}
  end

  def handle_event("save", _, %{assigns: %{postable?: false}} = socket), do: {:noreply, socket}

  def handle_event("save", %{"skill_evidence_post" => params, "help" => help}, socket) do
    %{
      uploads: uploads,
      me: me,
      skill_evidence: skill_evidence,
      user: user,
      skill: skill
    } = socket.assigns

    image_names = Enum.map(uploads.image.entries, & &1.client_name)
    help? = help == "on" && me
    params = Map.update!(params, "content", &maybe_append_help(&1, help?))

    # NOTE: 保存処理
    #   複数ファイルアップロードで意図的にMultiを使用していない。
    #   部分的に失敗した場合に元レコードまでなかったことにすると成功済みファイル有無も不明になるため。
    SkillEvidences.create_skill_evidence_post(skill_evidence, user, params, image_names)
    |> case do
      {:ok, skill_evidence_post} ->
        upload_files(socket, skill_evidence_post.image_paths)
        skill_evidence_post = Bright.Repo.preload(skill_evidence_post, user: [:user_profile])

        maybe_make_filled(user, skill, me)
        maybe_make_notification_evidence_by_help(user, skill_evidence, help?)
        maybe_make_notification_evidence_by_other_post(user, skill_evidence, me)

        {:noreply,
         socket
         |> stream_insert(:skill_evidence_posts, skill_evidence_post, at: -1)
         |> assign(:entry_errors, [])
         |> assign_form()}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("delete", %{"id" => skill_evidence_post_id}, socket) do
    # TODO: 画面からはボタンを消しているがサーバ側として権限確認が必要
    SkillEvidences.get_skill_evidence_post!(skill_evidence_post_id)
    |> SkillEvidences.delete_skill_evidence_post()
    |> case do
      {:ok, %{delete: skill_evidence_post}} ->
        {:noreply,
         socket
         |> stream_delete(:skill_evidence_posts, skill_evidence_post)}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("cancel_upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :image, ref)}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp assign_form(socket) do
    skill_evidence_post = %SkillEvidences.SkillEvidencePost{}
    changeset = SkillEvidences.change_skill_evidence_post(skill_evidence_post)

    socket
    |> assign(:skill_evidence_post, skill_evidence_post)
    |> assign_form(changeset)
  end

  defp upload_files(socket, storage_paths) do
    [socket.assigns.uploads.image.entries, storage_paths]
    |> Enum.zip()
    |> Enum.map(fn {%{valid?: true} = entry, storage_path} ->
      consume_uploaded_entry(socket, entry, fn %{path: path} ->
        Storage.upload!(path, storage_path)
        {:ok, :uploaded}
      end)
    end)
  end

  defp maybe_append_help(content, help)

  defp maybe_append_help("", _help), do: ""

  defp maybe_append_help(content, false), do: content

  defp maybe_append_help(content, true) do
    Enum.join([content, @help_message], "\n")
  end

  defp maybe_make_filled(user, skill, me)

  defp maybe_make_filled(_user, _skill, false), do: nil

  defp maybe_make_filled(user, skill, true) do
    SkillScores.make_skill_score_evidence_filled(user, skill)
  end

  defp maybe_make_notification_evidence_by_help(user, skill_evidence, help)

  defp maybe_make_notification_evidence_by_help(_user, _skill_evidence, false), do: nil

  defp maybe_make_notification_evidence_by_help(user, skill_evidence, true) do
    SkillEvidences.help(skill_evidence, user)
  end

  defp maybe_make_notification_evidence_by_other_post(user, skill_evidence, me)

  defp maybe_make_notification_evidence_by_other_post(_user, _skill_evidence, true), do: nil

  defp maybe_make_notification_evidence_by_other_post(user, skill_evidence, false) do
    SkillEvidences.receive_post(skill_evidence, user)
  end

  defp icon_file_path(_user, true), do: UserProfiles.icon_url(nil)

  defp icon_file_path(user, _anonymous) do
    UserProfiles.icon_url(user.user_profile.icon_file_path)
  end

  defp image_url(image_path) do
    Storage.public_url(image_path)
  end

  defp deletable_user?(skill_evidence_post, skill_evidence, user) do
    SkillEvidences.can_delete_skill_evidence_post?(skill_evidence_post, skill_evidence, user)
  end

  defp postable_user?(skill_evidence, user) do
    SkillEvidences.can_write_skill_evidence?(skill_evidence, user)
  end

  defp unassign_invalid_image_entries(socket) do
    uploads = socket.assigns.uploads
    invalids = Enum.filter(uploads.image.entries, &(!&1.valid?))
    errors = invalids |> Enum.flat_map(&upload_errors(uploads.image, &1)) |> Enum.uniq()

    invalids
    |> Enum.reduce(socket, fn invalid, acc ->
      cancel_upload(acc, :image, invalid.ref)
    end)
    |> assign(:entry_errors, errors)
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
        placeholder="学習メモを入力"
        class="w-full min-h-1 outline-none border-none focus:ring-0 p-2"
      ><%= Phoenix.HTML.Form.normalize_value("textarea", @value) %></textarea>
      <div>
        <.error :for={msg <- @errors}><%= msg %></.error>
      </div>
    </div>
    """
  end
end

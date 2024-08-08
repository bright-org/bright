defmodule BrightWeb.MypageLive.MySkillEvidencesComponent do
  @moduledoc """
  画面表示対象者の学習メモの表示用

  「さらに表示」をpageで管理している
  """

  @page_size 10

  use BrightWeb, :live_component

  import BrightWeb.SkillEvidenceComponents

  alias Bright.SkillUnits
  alias Bright.SkillEvidences

  def render(assigns) do
    ~H"""
    <section id={@id}>
      <h5 class="text-base lg:text-lg">学習メモ</h5>
      <div
        :if={@page_number ==  0}
        class="bg-white rounded-md mt-1 px-2 py-0.5 text-sm font-medium gap-y-2 flex py-2 my-2"
      >
        まだ学習メモがありません
      </div>

      <div id="skill-evidences" phx-update="stream">
        <div
          :for={{id, skill_evidence} <- @streams.skill_evidences}
          id={id}
          class="bg-white rounded-md mt-1 px-2 py-0.5 text-sm font-medium gap-y-2 flex py-2 my-2"
        >
          <.skill_evidence
            myself={@myself}
            skill_evidence={skill_evidence}
            skill_evidence_post={get_latest_skill_evidence_post(skill_evidence)}
            skill_breadcrumb={SkillEvidences.get_skill_breadcrumb(%{id: skill_evidence.skill_id})}
            current_user={@current_user}
            anonymous={@anonymous}
            related_user_ids={@related_user_ids}
            display_time={true}
          />
        </div>
      </div>

      <div :if={@read_more} class="bg-white rounded-md px-2 py-2 my-2 text-sm font-medium">
        <button id="btn-#{@id}-read-more" class="w-full" phx-click="read_more" phx-target={@myself}>
          さらに表示
        </button>
      </div>
    </section>
    """
  end

  def mount(socket) do
    {:ok,
     socket
     |> assign(:page_number, 0)
     |> assign(:read_more, false)
     |> stream(:skill_evidences, [])}
  end

  def update(%{reload_skill_evidence: true} = assigns, socket) do
    # 更新時再取得
    # 画面初期表示は最新を上に表示するが、本処理後に位置を動かすと混乱するため同じ位置のままにしている
    %{skill_evidence_id: skill_evidence_id} = assigns

    skill_evidence =
      SkillEvidences.get_skill_evidence!(skill_evidence_id)
      |> Bright.Repo.preload(skill_evidence_posts: [user: [:user_profile]])

    {:ok, stream_insert(socket, :skill_evidences, skill_evidence)}
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> load_recent_skill_evidences()}
  end

  def handle_event("read_more", _params, socket) do
    {:noreply, load_recent_skill_evidences(socket)}
  end

  def handle_event("edit_skill_evidence", %{"id" => id}, socket) do
    %{current_user: current_user} = socket.assigns
    skill_evidence = SkillEvidences.get_skill_evidence!(id)
    skill = SkillUnits.get_skill!(skill_evidence.skill_id)

    # モーダルを開き、表示内容を選択した学習メモで初期化する
    # モーダルを閉じたときは、最新にするupdateを実行する
    send_update(BrightWeb.ModalComponent,
      id: "skill-evidence-modal",
      open: true,
      on_open: fn ->
        send_update(BrightWeb.SkillPanelLive.SkillEvidenceComponent,
          id: "skill-evidence",
          reset: true,
          skill_evidence: skill_evidence,
          skill: skill,
          user: current_user,
          me: current_user.id == skill_evidence.user_id
        )
      end,
      on_close: fn ->
        send_update(__MODULE__,
          id: socket.assigns.id,
          reload_skill_evidence: true,
          skill_evidence_id: skill_evidence.id
        )
      end
    )

    {:noreply, socket}
  end

  defp load_recent_skill_evidences(socket) do
    %{display_user: display_user, page_number: page_number} = socket.assigns

    page =
      SkillEvidences.page_recent_skill_evidences([display_user.id],
        page: page_number + 1,
        page_size: @page_size
      )

    entries =
      Bright.Repo.preload(page.entries, skill_evidence_posts: [user: [:user_profile]])
      |> Enum.filter(&(&1.skill_evidence_posts != []))

    page_number = if(entries != [], do: page_number + 1, else: page_number)

    Enum.reduce(entries, socket, fn skill_evidence, acc ->
      stream_insert(acc, :skill_evidences, skill_evidence)
    end)
    |> assign(:page_number, page_number)
    |> assign(:read_more, page.total_entries != 0 && page.total_pages > page_number)
  end

  defp get_latest_skill_evidence_post(skill_evidence) do
    skill_evidence.skill_evidence_posts
    |> Enum.sort_by(& &1.inserted_at, {:desc, NaiveDateTime})
    |> List.first()
  end
end

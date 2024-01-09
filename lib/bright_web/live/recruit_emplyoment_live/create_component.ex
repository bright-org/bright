defmodule BrightWeb.RecruitEmploymentLive.CreateComponent do
  use BrightWeb, :live_component

  alias Bright.Recruits
  alias Bright.Recruits.Employment
  alias BrightWeb.BrightCoreComponents, as: BrightCore

  import BrightWeb.ProfileComponents, only: [profile: 1]
  import Bright.UserProfiles, only: [icon_url: 1]

  @impl true
  def render(assigns) do
    ~H"""
    <div id="notification_modal">
      <div class="bg-pureGray-600/90 transition-opacity z-[55]" />
      <div class="overflow-y-visible z-[60]">
        <main class="flex items-center justify-center" role="main">
          <section class="bg-white px-10 py-4 shadow text-sm w-[60vw]">
            <h2 class="font-bold text-3xl">
              <span class="before:bg-bgGemSales before:bg-9 before:bg-left before:bg-no-repeat before:content-[''] before:h-9 before:inline-block before:relative before:top-[8px] before:w-9">採用連絡</span>
            </h2>
            <p class="mt-2 text-lg">※不採用を連絡時の理由は候補者には送信されません</p>
            <div class="mt-8">
              <div class="pb-4">
              <.profile
                  user_name={@coordination.candidates_user.name}
                  title={@coordination.candidates_user.user_profile.title}
                  icon_file_path={icon_url(@coordination.candidates_user.user_profile.icon_file_path)}

              />
              </div>
              <.form
                for={@employment_form}
                id="employment_form"
                phx-target={@myself}
                phx-submit="create_employment"
                phx-change="validate"
              >
              <h3 class="font-bold">メッセージ</h3>
              <div class="flex gap-x-4 mt-4">
                <.button
                  type="button"
                  phx-target={@myself}
                  phx-click="insert_sample" phx-value-sample="none"
                >
                  何も入れない
                </.button>
                <.button
                  type="button"
                  phx-target={@myself}
                  phx-click="insert_sample" phx-value-sample="adopted"
                >
                  採用サンプルを入れる
                </.button>
                <.button
                  type="button"
                  phx-target={@myself}
                  phx-click="insert_sample" phx-value-sample="not_adopted"
                >
                  不採用サンプルを入れる
                </.button>
              </div>
              <div class="mt-6 overflow-y-auto">
                  <BrightCore.input
                      error_class="ml-[100px] mt-2"
                      field={@employment_form[:message]}
                      type="textarea"
                      required
                      rows="6"
                      cols="30"
                      input_class="border border-brightGray-300 px-2 py-1 rounded w-full"
                    />

                <label class="items-center flex mt-8 w-full">
                  <span class="font-bold -pt-2 mr-4">年収もしくは契約額</span>
                  <BrightCore.input
                      error_class="ml-[100px] mt-2"
                      field={@employment_form[:income]}
                      type="number"
                      size="20"
                      input_class="border border-brightGray-200 px-2 py-1 rounded w-40"
                    />
                  <span class="ml-1">万円</span>
                </label>
                <label class="items-center flex mt-8 w-full">
                  <span class="font-bold -pt-2 mr-4">契約形態</span>
                  <BrightCore.input
                      error_class="ml-[100px] mt-2"
                      field={@employment_form[:employment_status]}
                      options={@options}
                      type="select"
                      prompt="契約形態を選択してください"
                      input_class="border border-brightGray-200 px-2 py-1 rounded w-80"
                    />
                </label>

              </div>

              <div class="flex justify-center gap-x-4 mt-16 pb-2 relative w-full">
                <button class="text-sm font-bold py-3 rounded border border-base w-44 h-12">
                  <.link navigate={@patch}>閉じる</.link>
                </button>

                <div>
                    <button
                      phx-click={JS.show(to: "#menu01")}
                      type="button"
                      class="text-sm font-bold py-3 pl-3 rounded text-white bg-base w-44 flex items-center"
                    >
                      <span class="min-w-[6em]">不採用を連絡する</span>
                      <span class="material-icons relative ml-2 px-1 before:content[''] before:absolute before:left-0 before:top-[-9px] before:bg-brightGray-200 before:w-[1px] before:h-[42px]">add</span>
                    </button>

                    <div
                      id="menu01"
                      phx-click-away={JS.hide(to: "#menu01")}
                      class="hidden absolute bg-white rounded-lg shadow-md min-w-[286px]"
                    >
                      <ul class="p-2 text-left text-base">
                        <li
                          phx-click={JS.push("decision", target: @myself, value: %{decision: :cancel_coordination, reason: "候補者の希望条件に添えない"})}
                          class="block px-4 py-3 hover:bg-brightGray-50 text-base cursor-pointer"
                        >
                          候補者の希望条件に添えない
                        </li>
                        <li
                          phx-click={JS.push("decision", target: @myself, value: %{decision: :cancel_coordination, reason: "候補者のスキルが案件とマッチしない"})}
                          class="block px-4 py-3 hover:bg-brightGray-50 text-base cursor-pointer"
                        >
                          候補者のスキルが案件とマッチしない
                        </li>
                        <li
                          phx-click={JS.push("decision", target: @myself, value: %{decision: :cancel_coordination, reason: "候補者のスキルが登録内容より不足"})}
                          class="block px-4 py-3 hover:bg-brightGray-50 text-base cursor-pointer"
                        >
                          候補者のスキルが登録内容より不足
                        </li>
                        <li
                          phx-click={JS.push("decision", target: @myself, value: %{decision: :cancel_coordination, reason: "当方の状況が変わって中断"})}
                          class="block px-4 py-3 hover:bg-brightGray-50 text-base cursor-pointer"
                        >
                          当方の状況が変わって中断
                        </li>
                      </ul>
                    </div>
                  </div>

                <button class="text-sm font-bold px-2 py-2 rounded border bg-base text-white w-40">
                  採用を連絡する
                </button>

              </div>
              </.form>
            </div>
          </section>
        </main>
      </div>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(%{coordination_id: coordination_id, current_user: current_user} = assigns, socket) do
    coordination = Recruits.get_coordination_with_profile!(coordination_id, current_user.id)
    employment = %Employment{}
    changeset = Recruits.change_employment(employment)

    options =
      Recruits.Employment
      |> Ecto.Enum.mappings(:employment_status)
      |> Enum.map(fn {_k, v} -> {Gettext.gettext(BrightWeb.Gettext, v), v} end)

    socket
    |> assign(assigns)
    |> assign(:coordination, coordination)
    |> assign(:employment, employment)
    |> assign(:options, options)
    |> assign_employment_form(changeset)
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_event("validate", %{"employment" => employment_params}, socket) do
    changeset =
      socket.assigns.employment
      |> Employment.changeset(employment_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_employment_form(socket, changeset)}
  end

  def handle_event("insert_sample", %{"sample" => sample}, socket) do
    candidates_user = socket.assigns.coordination.candidates_user.name

    changeset =
      socket.assigns.employment
      |> Employment.changeset(sample_message(sample, candidates_user))

    {:noreply, assign_employment_form(socket, changeset)}
  end

  def handle_event("create_employment", %{"employment" => employment_params}, socket) do
    coordination = socket.assigns.coordination
    recruiter = socket.assigns.current_user

    employment_params =
      Map.merge(employment_params, %{
        "recruiter_user_id" => recruiter.id,
        "candidates_user_id" => coordination.candidates_user_id
      })

    case Recruits.create_employment(employment_params) do
      {:ok, employment} ->
        Recruits.get_coordination!(coordination.id)
        |> Recruits.update_coordination(%{status: :completed_coordination})

        send_acceptance_mails(employment, coordination, recruiter)

        {:noreply, redirect(socket, to: ~p"/recruits/employments")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_employment_form(socket, changeset)}
    end
  end

  def handle_event("decision", %{"reason" => reason}, socket) do
    params = socket.assigns.employment_form.params
    coordination = socket.assigns.coordination
    recruiter = socket.assigns.current_user

    employment_params =
      Map.merge(
        params,
        %{
          "recruiter_user_id" => recruiter.id,
          "candidates_user_id" => coordination.candidates_user_id,
          "cancel_reason" => reason
        }
      )

    Recruits.cancel_employment(employment_params)

    {:ok, _coordination} =
      Recruits.update_coordination(coordination, %{
        status: :cancel_coordination,
        cancel_reason: reason
      })

    Recruits.send_coordination_cancel_notification_mails(coordination.id, params["message"])

    {:noreply, push_navigate(socket, to: ~p"/recruits/coordinations")}
  end

  defp send_acceptance_mails(employment, coordination, recruiter) do
    Recruits.deliver_acceptance_employment_email_instructions(
      recruiter,
      coordination.candidates_user,
      employment,
      &url(~p"/recruits/coordinations/acceptance/#{&1}")
    )
  end

  defp assign_employment_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :employment_form, to_form(changeset))
  end

  defp sample_message("none", _), do: %{"message" => ""}
  defp sample_message("adopted", _name), do: %{"message" => "採用"}

  defp sample_message("not_adopted", name) do
    message = """
    この度は、多数の企業の中から弊社にご応募いただき、誠にありがとうございました。
    応募書類をもとに慎重に選考しましたところ、誠に残念ではございますが、今回はご期待に添いかねる結果となりました。
    大変申し訳ございませんが、ご了承くださいますようお願い申し上げます。

    ご応募いただいたことにお礼申し上げると共に、略式ながらメールにて通知申し上げます。
    末筆になりますが、#{name}様のこれからのご活躍を心よりお祈り申し上げます。
    """

    %{"message" => message}
  end
end

defmodule BrightWeb.SearchLive.UserSearchComponent do
  use BrightWeb, :live_component

  alias Bright.{CareerFields, SkillPanels, Accounts}
  alias Bright.SearchForm.{UserSearch, SkillSearch}
  alias Bright.UserJobProfiles.UserJobProfile
  alias BrightWeb.SearchLive.SearchResultComponent
  alias BrightWeb.BrightCoreComponents, as: BrightCore

  @class [クラス1: "class1", クラス2: "class2", クラス3: "class3"]
  @level [見習い: "beginner", 平均: "normal", ベテラン: "skilled"]

  @impl true
  def render(assigns) do
    ~H"""
    <li class="block">
      <.form
        for={@form}
        id="user_search_form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="search"
      >
      <div class="border-b border-brightGray-200 flex flex-wrap items-center">
        <div class="flex items-center w-fit">
          <label class="flex items-center py-4">
            <span class="w-24">PJ期間</span>
            <BrightCore.input
              field={@form[:pj_start]}
              input_class="border border-brightGray-200 px-2 py-1  rounded w-30"
              type="date"
              size="20"
            />
            <span class="mx-1">～</span>
            <BrightCore.input
              field={@form[:pj_end]}
              input_class="border border-brightGray-200 px-2 py-1  rounded w-30"
              type="date"
              size="20"
            />
          </label>

          <label class="flex items-center ml-2">
          <BrightCore.input
                field={@form[:pj_end_undecided]}
                input_class="border border-brightGray-200 rounded"
                label_class="ml-1 text-xs"
                type="checkbox"
                label="終了日未定"
              />
          </label>
        </div>

        <div class="ml-auto w-fit">
          <label class="flex items-center py-4">
            <span class="w-24">希望年収<span class="block text-xs">（一人当たり）</span></span>
            <BrightCore.input
              field={@form[:budget]}
              input_class="border border-brightGray-200 px-2 py-1 rounded w-40"
              size="20"
              type="number"
            />
          </label>
        </div>
      </div>

      <div class="border-b border-brightGray-200 flex flex-wrap py-4 w-full">
        <span class="py-1 w-32">勤務体系</span>
        <div class="-ml-8">
          <div class="flex items-center">
            <BrightCore.input
              field={@form[:office_work]}
              label_class="w-16 text-left"
              type="checkbox"
              label="出勤"
            />
            <BrightCore.input
              field={@form[:office_pref]}
              input_class="w-36"
              disabled={disabled?(@form[:office_work].value)}
              type="select"
              options={Ecto.Enum.mappings(UserJobProfile, :office_pref)}
              prompt="希望勤務地"
            />
            <BrightCore.input
              field={@form[:office_work_hours]}
              input_class="w-36"
              disabled={disabled?(@form[:office_work].value)}
              type="select"
              options={Ecto.Enum.mappings(UserJobProfile, :office_working_hours)}
              prompt="希望勤務時間"
            />
            <BrightCore.input
              field={@form[:office_work_holidays]}
              container_class="ml-4"
              disabled={disabled?(@form[:office_work].value)}
              type="checkbox"
              label_class={if disabled?(@form[:office_work].value), do: "opacity-50"}
              label="土日祝の稼働も含む"
            />
          </div>

          <div class="flex items-center mt-2">
            <BrightCore.input
              field={@form[:remote_work]}
              label_class="w-16 text-left"
              type="checkbox"
              label="リモート"
            />
            <BrightCore.input
              field={@form[:remote_work_huors]}
              input_class="w-36"
              disabled={disabled?(@form[:remote_work].value)}
              type="select"
              options={Ecto.Enum.mappings(UserJobProfile, :remote_working_hours)}
              prompt="希望勤務時間"
            />
            <BrightCore.input
              field={@form[:remote_work_holidays]}
              container_class="ml-4"
              disabled={disabled?(@form[:remote_work].value)}
              type="checkbox"
              label_class={if disabled?(@form[:remote_work].value), do: "opacity-50"}
              label="土日祝の稼働も含む"
            />
          </div>
        </div>
      </div>

      <div class="flex mt-4" id="skill_section">
        <span class="mt-2 w-24">スキル</span>
        <div class="-ml-5">
        <.inputs_for :let={sk} field={@form[:skills]} >
          <input type="hidden" name="user_search[skills_sort][]" value={sk.index}>
          <div class="flex items-center mb-4">
            <label class="cursor-pointer" :if={sk.index > 0}>
              <input
                type="checkbox"
                name="user_search[skills_drop][]"
                value={sk.index}
                class="hidden"
              />
              <i class="delete_skill_conditions bg-attention-600 block border border-attention-600 cursor-pointer h-4 indent-40 -ml-5 mr-1 overflow-hidden relative rounded-full w-4 before:top-1/2 before:left-1/2 before:-ml-1 before:-mt-px before:content-[''] before:block before:absolute before:w-2 before:h-0.5 before:bg-white hover:opacity-50">スキル削除</i>
            </label>

            <BrightCore.input
              field={sk[:career_field]}
              input_class="border border-brightGray-200 mr-2 px-2 py-1 rounded w-46 text-md"
              type="select"
              options={@career_fields}
              prompt="キャリアフィールド"
            />
            <BrightCore.input
              field={sk[:skill_panel]}
              input_class="border border-brightGray-200 mr-2 px-2 py-1 rounded w-44"
              type="select"
              options={@skill_panels}
              prompt="スキルパネル"
            />
            <BrightCore.input
              field={sk[:class]}
              input_class="border border-brightGray-200 mr-2 px-2 py-1 rounded w-26"
              type="select"
              options={@class}
              prompt="クラス"
            />
            <BrightCore.input
              field={sk[:level]}
              input_class="border border-brightGray-200 mr-2 px-2 py-1 rounded w-26"
              type="select"
              options={@level}
              prompt="レベル"
            />
            <a
              class="bg-white border border-solid border-brightGray-900 cursor-pointer font-bold ml-6 px-2 py-1 rounded select-none text-center text-brightGray-900 w-44 hover:opacity-50"
            >
              スキル詳細も設定
            </a>
          </div>
        </.inputs_for>
        </div>
      </div>
      <label class="block cursor-pointer" :if={Enum.count(@form[:skills].value) < 3}>
        <input type="checkbox" name="user_search[skills_sort][]" class="hidden" />
        <i id="set_skill_conditions" class="bg-brightGreen-900 block border border-brightGreen-900 cursor-pointer h-4 indent-40 mx-auto overflow-hidden relative rounded-full w-4 before:top-1/2 before:left-1/2 before:-ml-1 before:-mt-px before:content-[''] before:block before:absolute before:w-2 before:h-0.5 before:bg-white after:top-1/2 after:left-1/2 after:-ml-1 after:-mt-px after:content-[''] after:block after:absolute after:w-2 after:h-0.5 after:bg-white after:rotate-90 hover:opacity-50">追加</i>
      </label>

      <div class="flex mt-16 mx-auto w-fit">
        <BrightCore.button phx-disable-with="Searching...">検索する</BrightCore.button>
      </div>
      </.form>
      <.live_component
        id="user_search_result"
        module={SearchResultComponent}
        current_user={@current_user}
        result={@search_results}
      />
    </li>
    """
  end

  @impl true
  def mount(socket) do
    form = %UserSearch{skills: [%SkillSearch{}]}
    changeset = UserSearch.changeset(form, %{})

    career_fields =
      CareerFields.list_career_fields()
      |> Enum.map(&{&1.name_ja, &1.name_en})

    skill_panels =
      SkillPanels.list_skill_panels()
      |> Enum.map(&{&1.name, &1.id})

    socket
    |> assign(:user_search, form)
    |> assign(:career_fields, career_fields)
    |> assign(:skill_panels, skill_panels)
    |> assign(:class, @class)
    |> assign(:level, @level)
    |> assign(:search_results, [])
    |> assign_form(changeset)
    |> then(&{:ok, &1})
  end

  @impl true
  def update(assigns, socket), do: {:ok, assign(socket, assigns)}

  @impl true
  def handle_event("validate", %{"user_search" => user_search_params}, socket) do
    changeset =
      socket.assigns.user_search
      |> UserSearch.changeset(user_search_params)
      |> Map.put(:action, :validte)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("search", _params, socket) do
    users = Accounts.list_users_without_current_user_dev(socket.assigns.current_user.id)
    {:noreply, assign(socket, :search_results, users)}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  def disabled?(bool_or_string), do: to_string(bool_or_string) == "false"
end

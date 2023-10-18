defmodule BrightWeb.TeamLive.TeamAddUserComponent do
  use BrightWeb, :live_component

  alias Bright.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-w-[580px] pr-10 border-r border-r-brightGray-200 border-dashed">
    <!-- TODO α対象外
      <p>
        <span class="font-bold">気になる</span>からメンバーとして追加
      </p>

      <p>
        <span class="font-bold">関わっているチーム</span>からサブチームとして追加
      </p>
    -->
      <div class="flex items-center">
        <form
          id="add_user_form"
          phx-target={@myself}
          phx-submit="add_user"
        >
          <p class="pb-2 text-base">
            <span class="font-bold">Brightハンドル名</span>からメンバーとして追加
          </p>
          <input
            id="search_word"
            name="search_word"
            type="autocomplete"
            placeholder="ハンドル名を入力してください"
            class="px-5 py-2 border border-brightGray-100 rounded-sm flex-1 w-[390px]"
            phx-change="change_add_user"
            value={@search_word}
          />
          <button
            phx-target={@myself}
            class="text-sm font-bold px-5 py-2 rounded border border-base ml-2.5"
          >
            追加
          </button>
        </form>
      </div>
      <div :if={@search_word_error != nil}>
        <p class= "text-error text-xs"><%= @search_word_error %></p>
      </div>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    socket
    |> assign(:search_word, nil)
    |> assign(:search_word_error, nil)
    |> then(&{:ok, &1})
  end

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  @impl true
  def handle_event("change_add_user", %{"search_word" => search_word}, socket) do
    {:noreply, assign(socket, :search_word, search_word)}
  end

  def handle_event("add_user", _params, socket) do
    search_word = socket.assigns.search_word

    socket
    |> validate_search_word(search_word)
    |> search_and_add_user(search_word)
    |> then(&{:noreply, &1})
  end

  defp validate_search_word(socket, search_word) do
    if is_nil(search_word) || search_word == "" do
      {:error, assign(socket, search_word_error: "検索条件を入力してください")}
    else
      {:ok, socket}
    end
  end

  defp search_and_add_user({:error, socket}, _search_word), do: socket

  defp search_and_add_user({:ok, socket}, search_word) do
    search_and_add_user(socket, Accounts.get_user_by_name_or_email(search_word))
  end

  defp search_and_add_user(socket, nil),
    do: assign(socket, search_word_error: "該当のユーザーが見つかりませんでした")

  defp search_and_add_user(socket, user) when user.id == socket.assigns.current_user.id,
    do: assign(socket, search_word_error: "チーム作成者は自動的に管理者として追加されます")

  defp search_and_add_user(socket, user) do
    selected_users = socket.assigns.users

    if id_duplidated_user?(user, selected_users) do
      socket
      # TODO Gettext未対応
      |> assign(search_word_error: "対象のユーザーは既に追加されています")
    else
      # メンバーユーザー一時リストに追加
      notify_parent({:add, selected_users ++ [user]})

      socket
      |> assign(:search_word, nil)
      |> assign(:search_word_error, nil)
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp id_duplidated_user?(user, users) do
    users |> Enum.find(fn u -> user.id == u.id end) |> is_nil() |> then(&(!&1))
  end
end

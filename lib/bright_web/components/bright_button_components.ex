defmodule BrightWeb.BrightButtonComponents do
  @moduledoc """
  Bright Button Components
  """
  use Phoenix.Component

  @doc """
  Renders a "Excellent Person" Button

  ## Examples
      <.excellent_person_button />
  """
  def excellent_person_button(assigns) do
    ~H"""
    <button
      type="button"
      class="text-gray-900 bg-white px-2 py-1 inline-flex font-medium rounded-md text-sm items-center border border-brightGreen-300"
    >
      <span class="material-icons md-18 mr-1 text-brightGreen-300">share</span> 優秀な人として紹介
    </button>
    """
  end

  @doc """
  Renders a "Anxious Person" Button

  ## Examples
      <.anxious_person_button />
  """
  def anxious_person_button(assigns) do
    ~H"""
    <button
      type="button"
      id="dropcheckmenu"
      data-dropdown-toggle="checkmenu"
      class="text-gray-900 bg-white px-2 py-1 inline-flex font-medium rounded-md text-sm items-center border border-brightGray-200"
    >
      <span class="material-icons md-18 mr-1 text-brightGray-200">star</span> 気になる
    </button>
    <!-- 気になるDropdown menu -->
    <div id="checkmenu" class="z-10 hidden bg-white rounded-lg shadow min-w-[286px]">
      <ul class="p-2 text-left text-base" aria-labelledby="dropcheckmenu">
        <li>
          <a href="#" class="block px-4 py-3 hover:bg-brightGray-50 text-base">気になるリスト</a>
        </li>
        <li>
          <a href="#" class="block px-4 py-3 hover:bg-brightGray-50 text-base">メンバー候補</a>
        </li>
        <li>
          <a href="#" class="block px-4 py-3 hover:bg-brightGray-50 text-base">
            java開発者リスト
          </a>
        </li>
        <li>
          <a href="#" class="block px-4 py-3 hover:bg-brightGray-50 text-base">
            Python開発者リスト
          </a>
        </li>
        <li>
          <a href="#" class="block px-4 py-3 hover:bg-brightGray-50 text-base">
            ジュニアエンジニア
          </a>
        </li>
        <li>
          <a href="#" class="block px-4 py-3 hover:bg-brightGray-50 text-base">
            シニアエンジニア
          </a>
        </li>
        <li class="px-4 py-3 hover:bg-brightGray-50 flex justify-center gap-x-2">
          <input
            type="text"
            placeholder="リスト名を入力"
            class="px-2 py-1 border border-brightGray-900 rounded-sm flex-1 w-full text-base w-[220px]"
          />
          <button class="text-sm font-bold px-4 py-1 rounded text-white bg-base">
            新規作成
          </button>
        </li>
      </ul>
    </div>
    """
  end

  @doc """
  Renders a "Return to Yourself" Button

  ## Examples
      <.return_to_yourself_button />
  """
  def return_to_yourself_button(assigns) do
    ~H"""
    <button
      type="button"
      class="text-brightGreen-300 bg-white px-2 py-1 inline-flex rounded-md text-sm items-center border border-brightGreen-300 font-bold"
    >
      自分に戻す
    </button>
    """
  end

  @doc """
  Renders a "Stock Candidates For Employment" Button

  ## Examples
      <.stock_candidates_for_employment_button />
  """
  def stock_candidates_for_employment_button(assigns) do
    ~H"""
    <button
      type="button"
      class="text-brightGreen-300 bg-white px-2 py-1 inline-flex rounded-md text-sm items-center border border-brightGreen-300 font-bold"
    >
      採用候補者としてストック
    </button>
    """
  end

  @doc """
  Renders a Adopt Button

  ## Examples
      <.adopt_button />
  """
  def adopt_button(assigns) do
    ~H"""
    <button
      type="button"
      class="text-brightGreen-300 bg-white px-2 py-1 inline-flex rounded-md text-sm items-center border border-brightGreen-300 font-bold"
    >
      採用する
    </button>
    """
  end

  @doc """
  Renders a "Recruitment Coordination" Button

  ## Examples
      <.ecruitment_coordination_button />
  """
  def ecruitment_coordination_button(assigns) do
    ~H"""
    <button
      type="button"
      class="text-brightGreen-300 bg-white px-2 py-1 inline-flex rounded-md text-sm items-center border border-brightGreen-300 font-bold"
    >
      採用の調整
    </button>
    """
  end
end

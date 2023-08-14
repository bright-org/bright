defmodule BrightWeb.SearchLive.Index do
  use BrightWeb, :live_view

  alias Bright.UserJobProfiles.UserJobProfile
  alias BrightWeb.BrightCoreComponents, as: BrightCore

  def render(assigns) do
    ~H"""
      <section class="absolute bg-white min-h-[600px] p-4 right-0 shadow text-sm top-[60px] w-[1000px]">
    <!-- Start タブメニュー -->
    <ul id="account_settings_tab" class="border-b border-brightGray-200 flex">
      <li class="border-b-2 border-brightGreen-300 cursor-pointer py-3.5 text-center w-40 hover:bg-brightGray-50">ユーザー検索</li>
      <!-- αでは落とす
      <li class="cursor-pointer py-3.5 select-none text-center w-40 hover:bg-brightGray-50">チーム検索</li>
      -->
    </ul><!-- End タブメニュー -->

    <form>
      <ul id="account_settings_content">
    <!-- Start ユーザー検索 -->
        <li class="block">
          <div class="border-b border-brightGray-200 flex flex-wrap items-center">
            <div class="flex items-center w-fit">
              <label class="flex items-center py-4">
                <span class="w-24">PJ期間</span>
                <input type="date" size="20" name="pj_start" class="border border-brightGray-200 px-2 py-1  rounded w-30">
                <span class="mx-1">～</span>
                <input type="date" size="20" name="pj_end" class="border border-brightGray-200 px-2 py-1  rounded w-30">
              </label>

              <label class="flex items-center ml-2">
                <input type="checkbox" name="pj_end_undecided" class="border border-brightGray-200 rounded">
                <span class="ml-1 text-xs">終了日未定</span>
              </label>
            </div>

            <div class="ml-auto w-fit">
              <label class="flex items-center py-4">
                <span class="w-24">月予算<span class="block text-xs">（一人当たり）</span></span>
                <input type="text" size="20" name="budget" class="border border-brightGray-200 px-2 py-1 rounded w-40">
              </label>
            </div>
          </div>

          <div class="border-b border-brightGray-200 flex flex-wrap py-4 w-full">
            <span class="py-1 w-32">勤務体系</span>
            <div class="-ml-8">
              <div class="flex items-center">
                <BrightCore.input
                  name="office_work"
                  value=""
                  label_class="w-16 text-left"
                  type="checkbox"
                  label="出勤"
                />
                <BrightCore.input
                  name="office_pref"
                  value=""
                  input_class="w-32"
                  type="select"
                  options={Ecto.Enum.mappings(UserJobProfile, :office_pref)}
                  prompt="希望勤務地"

                />
                <BrightCore.input
                  name="office_work_hours"
                  value=""
                  input_class="w-32"
                  type="select"
                  options={Ecto.Enum.mappings(UserJobProfile, :office_working_hours)}
                  prompt="希望勤務時間"

                />
                <BrightCore.input
                  name="office_work_holidays"
                  value=""
                  container_class="ml-4"
                  type="checkbox"
                  label="土日祝の稼働も含む"
                />
              </div>

              <div class="flex items-center mt-2">
                <BrightCore.input
                  name="remote_work"
                  value=""
                  label_class="w-16 text-left"
                  type="checkbox"
                  label="リモート"
                />
                <BrightCore.input
                  name="remote_work_huors"
                  value=""
                  input_class="w-32"
                  type="select"
                  options={Ecto.Enum.mappings(UserJobProfile, :remote_working_hours)}
                  prompt="希望勤務時間"
                />
                <BrightCore.input
                  name="remote_work_holidays"
                  value=""
                  container_class="ml-4"
                  type="checkbox"
                  label="土日祝の稼働も含む"
                />
              </div>
            </div>
          </div>

          <div class="flex mt-4" id="skill_section">
            <span class="mt-2 w-24">スキル</span>
            <div>
            <!-- Start スキル入力 -->
              <div id="search_skill_0" class="flex items-center mb-4">
                <i class="delete_skill_conditions bg-attention-600 block border border-attention-600 cursor-pointer h-4 indent-40 invisible -ml-5 mr-1 overflow-hidden relative rounded-full w-4 before:top-1/2 before:left-1/2 before:-ml-1 before:-mt-px before:content-[''] before:block before:absolute before:w-2 before:h-0.5 before:bg-white hover:opacity-50">スキル削除</i>

                <select name="skill" class="border border-brightGray-200 mr-2 px-2 py-1 rounded w-44">
                  <option value="">キャリアフィールド</option>
                  <option value="">エンジニア</option>
                  <option value="">インフラ</option>
                  <option value="">デザイナー</option>
                  <option value="">マーケッター</option>
                </select>

                <select name="skillset" class="border border-brightGray-200 mr-2 px-2 py-1 rounded w-44">
                  <option value="">ジョブ</option>
                  <option value="">（すべてのジョブが選択肢で表示されます）</option>
                  <option value="">選択肢</option>
                  <option value="">選択肢</option>
                </select>

                <select name="class" class="border border-brightGray-200 mr-2 px-2 py-1 rounded w-24">
                  <option value="">クラス</option>
                  <option value="">選択肢</option>
                  <option value="">選択肢</option>
                  <option value="">選択肢</option>
                </select>

                <select name="lebel" class="border border-brightGray-200 mr-2 px-2 py-1 rounded w-24">
                  <option value="">レベル</option>
                  <option value="">選択肢</option>
                  <option value="">選択肢</option>
                  <option value="">選択肢</option>
                </select>

                <a class="bg-white border border-solid border-brightGray-900 cursor-pointer font-bold ml-6 px-2 py-1 rounded select-none text-center text-brightGray-900 w-44 hover:opacity-50">スキル詳細も設定</a>
              </div><!-- End スキル入力 -->
            </div>
          </div>

          <i id="set_skill_conditions" class="bg-brightGreen-900 block border border-brightGreen-900 cursor-pointer h-4 indent-40 mx-auto overflow-hidden relative rounded-full w-4 before:top-1/2 before:left-1/2 before:-ml-1 before:-mt-px before:content-[''] before:block before:absolute before:w-2 before:h-0.5 before:bg-white after:top-1/2 after:left-1/2 after:-ml-1 after:-mt-px after:content-[''] after:block after:absolute after:w-2 after:h-0.5 after:bg-white after:rotate-90 hover:opacity-50">追加</i>

          <div class="flex mt-16 mx-auto w-fit">
            <a class="bg-brightGray-900 border border-solid border-brightGray-900 cursor-pointer font-bold px-4 py-2 rounded select-none text-center text-white w-80 hover:opacity-50">検索する</a>
          </div>
        </li><!-- End ユーザー検索 -->

    <!-- Start チーム検索 -->
        <li class="hidden">

        </li><!-- End チーム検索 -->
      </ul>
    </form>
    </section>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end

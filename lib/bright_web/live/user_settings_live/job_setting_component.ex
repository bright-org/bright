defmodule BrightWeb.UserSettingsLive.JobSettingComponent do
  use BrightWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <li class="block">
      <div class="border-b border-brightGray-200 flex flex-wrap">
        <div class="flex py-4">
          <span class="py-1 w-32">求職</span>
          <label class="flex items-center">
            <input type="radio" name="job_hunting" class="border border-brightGray-200" checked>
            <span class="ml-1">する</span>
          </label>

          <label class="flex items-center ml-4">
            <input type="radio" name="job_hunting" class="border border-brightGray-200">
            <span class="ml-1">しない</span>
          </label>
        </div>
      </div>

      <div class="border-b border-brightGray-200 flex flex-wrap">
        <div class="flex py-4">
          <span class="py-1 w-32">転職／副業</span>
          <label class="flex items-center">
            <input type="radio" name="job_change" class="border border-brightGray-200" checked>
            <span class="ml-1">転職</span>
          </label>

          <label class="flex items-center ml-4">
            <input type="radio" name="job_change" class="border border-brightGray-200">
            <span class="ml-1">副業</span>
          </label>
        </div>
      </div>

      <div class="border-b border-brightGray-200 flex flex-wrap">
        <label class="flex items-center py-4 w-full">
          <span class="w-32">就職可能日</span>
          <input type="date" size="20" name="title" class="border border-brightGray-200 px-2 py-1 rounded w-40">
        </label>
      </div>

      <div class="border-b border-brightGray-200 flex flex-wrap py-4">
        <span class="py-1 w-32">勤務体系</span>
        <div>
          <p class="flex items-center">
            <label class="flex items-center"><input type="checkbox" name="work_schedule"><span class="ml-1 w-16">出勤</span></label>
            <select name="work_location" class="border border-brightGray-200 ml-4 px-2 py-1 rounded">
              <option value="">希望勤務地</option>
              <option value="1">北海道</option>
              <option value="2">青森県</option>
              <option value="3">岩手県</option>
              <option value="4">宮城県</option>
              <option value="5">秋田県</option>
              <option value="6">山形県</option>
              <option value="7">福島県</option>
              <option value="8">茨木県</option>
              <option value="9">栃木県</option>
              <option value="10">群馬県</option>
              <option value="11">埼玉県</option>
              <option value="12">千葉県</option>
              <option value="13">東京都</option>
              <option value="14">神奈川県</option>
              <option value="15">新潟県</option>
              <option value="16">富山県</option>
              <option value="17">石川県</option>
              <option value="18">福井県</option>
              <option value="19">山梨県</option>
              <option value="20">長野県</option>
              <option value="21">岐阜県</option>
              <option value="22">静岡県</option>
              <option value="23">愛知県</option>
              <option value="24">三重県</option>
              <option value="25">滋賀県</option>
              <option value="26">京都府</option>
              <option value="27">大阪府</option>
              <option value="28">兵庫県</option>
              <option value="29">奈良県</option>
              <option value="30">和歌山県</option>
              <option value="31">鳥取県</option>
              <option value="32">島根県</option>
              <option value="33">岡山県</option>
              <option value="34">広島県</option>
              <option value="35">山口県</option>
              <option value="36">徳島県</option>
              <option value="37">香川県</option>
              <option value="38">愛媛県</option>
              <option value="39">高知県</option>
              <option value="40">福岡県</option>
              <option value="41">佐賀県</option>
              <option value="42">長崎県</option>
              <option value="43">熊本県</option>
              <option value="44">大分県</option>
              <option value="45">宮崎県</option>
              <option value="46">鹿児島県</option>
              <option value="47">沖縄県</option>
              <option value="48">海外</option>
            </select>

            <select name="working_hours" class="border border-brightGray-200 ml-4 px-2 py-1 rounded">
              <option value="">希望勤務時間</option>
              <option value="160">月160h以上</option>
              <option value="140">月140h～159h</option>
              <option value="120">月120h～139h</option>
              <option value="100">月100h～119h</option>
              <option value="80">月80h～99h</option>
              <option value="79">月79h以下</option>
            </select>

            <label class="flex items-center ml-4"><input type="checkbox" name="day_off"><span class="ml-1">土日の稼働も含む</span></label>
          </p>

          <p class="flex items-center mt-2">
            <label class="flex items-center"><input type="checkbox" name="remote"><span class="ml-1 w-16">リモート</span></label>

            <select name="remote_working_hours" class="border border-brightGray-200 ml-4 px-2 py-1 rounded">
              <option value="">希望勤務時間</option>
              <option value="160">月160h以上</option>
              <option value="140">月140h～159h</option>
              <option value="120">月120h～139h</option>
              <option value="100">月100h～119h</option>
              <option value="80">月80h～99h</option>
              <option value="79">月79h以下</option>
            </select>
            <label class="flex items-center ml-4"><input type="checkbox" name="remote_day_off"><span class="ml-1">土日の稼働も含む</span></label>

          </p>
        </div>
      </div>

      <div>
        <label class="items-center flex py-4 w-full">
          <span class="py-1 w-32">希望年収</span>
          <input type="number" size="20" name="income" class="border border-brightGray-200 px-2 py-1 rounded w-40">
          <span class="ml-1">万円以上</span>
        </label>
      </div>

      <div class="flex mt-8 mx-auto w-fit">
        <a class="bg-brightGray-900 border border-solid border-brightGray-900 cursor-pointer font-bold px-4 py-2 rounded select-none text-center text-white w-80 hover:opacity-50">保存する</a>
      </div>
    </li>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end
end

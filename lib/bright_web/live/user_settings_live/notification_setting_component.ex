defmodule BrightWeb.UserSettingsLive.NotificationSettingComponent do
  use BrightWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <li class="block">
      <!-- Start Daily通知 -->
      <div class="border-b border-brightGray-200 flex flex-wrap">
        <div class="flex items-center justify-between py-4 w-full">
          <div class="mr-4 py-1 w-96">
            <span>デイリー通知</span>
            <p class="text-xs">説明文</p>
          </div>

          <div class="bg-white border border-brightGray900 text-brightGray-500 pt-px rounded-full flex overflow-hidden text-sm font-bold h-6">
            <div>
              <input type="radio" id="notification_daily_off" name="notification_daily" value="off" class="peer sr-only">
              <label class="items-center px-4 py-0.5 peer-checked:bg-brightGreen-900 peer-checked:text-white" for="notification_daily_off">OFF</label>
            </div>
            <div class="-ml-[1px]">
              <input type="radio" id="notification_daily_on" name="notification_daily" value="on" class="peer sr-only" checked>
              <label class="items-center px-4 py-0.5 peer-checked:bg-brightGreen-900 peer-checked:text-white" for="notification_daily_on">ON</label>
            </div>
          </div>
        </div>
      </div><!-- End Daily通知 -->

      <!-- Start Weekly通知 -->
      <div class="border-b border-brightGray-200 flex flex-wrap">
        <div class="flex items-center justify-between py-4 w-full">
          <div class="mr-4 py-1 w-96">
            <span>ウィークリー通知</span>
            <p class="text-xs">説明文</p>
          </div>

          <div class="bg-white border border-brightGray900 text-brightGray-500 pt-px rounded-full flex overflow-hidden text-sm font-bold h-6">
            <div>
              <input type="radio" id="notification_weekly_off" name="notification_weekly" value="off" class="peer sr-only">
              <label class="items-center px-4 py-0.5 peer-checked:bg-brightGreen-900 peer-checked:text-white" for="notification_weekly_off">OFF</label>
            </div>
            <div class="-ml-[1px]">
              <input type="radio" id="notification_weekly_on" name="notification_weekly" value="on" class="peer sr-only" checked>
              <label class="items-center px-4 py-0.5 peer-checked:bg-brightGreen-900 peer-checked:text-white" for="notification_weekly_on">ON</label>
            </div>
          </div>
        </div>
      </div><!-- End Weekly通知 -->

      <!-- Start 定期通知 -->
      <div class="border-b border-brightGray-200 flex flex-wrap">
        <div class="flex items-center justify-between py-4 w-full">
          <div class="mr-4 py-1 w-96">
            <span>定期通知</span>
            <p class="text-xs">説明文</p>
          </div>

          <div class="bg-white border border-brightGray900 text-brightGray-500 pt-px rounded-full flex overflow-hidden text-sm font-bold h-6">
            <div>
              <input type="radio" id="notification_term_off" name="notification_term" value="off" class="peer sr-only">
              <label class="items-center px-4 py-0.5 peer-checked:bg-brightGreen-900 peer-checked:text-white" for="notification_term_off">OFF</label>
            </div>
            <div class="-ml-[1px]">
              <input type="radio" id="notification_term_on" name="notification_term" value="on" class="peer sr-only" checked>
              <label class="items-center px-4 py-0.5 peer-checked:bg-brightGreen-900 peer-checked:text-white" for="notification_term_on">ON</label>
            </div>
          </div>
        </div>
      </div><!-- End 定期通知 -->

      <!-- Start スキルパネル更新通知 -->
      <div class="border-b border-brightGray-200 flex flex-wrap">
        <div class="flex items-center justify-between py-4 w-full">
          <div class="mr-4 py-1 w-96">
            <span>スキルパネル更新通知</span>
            <p class="text-xs">説明文</p>
          </div>

          <div class="bg-white border border-brightGray900 text-brightGray-500 pt-px rounded-full flex overflow-hidden text-sm font-bold h-6">
            <div>
              <input type="radio" id="notification_skillpanel_off" name="notification_skillpanel" value="off" class="peer sr-only">
              <label class="items-center px-4 py-0.5 peer-checked:bg-brightGreen-900 peer-checked:text-white" for="notification_skillpanel_off">OFF</label>
            </div>
            <div class="-ml-[1px]">
              <input type="radio" id="notification_skillpanel_on" name="notification_skillpanel" value="on" class="peer sr-only" checked>
              <label class="items-center px-4 py-0.5 peer-checked:bg-brightGreen-900 peer-checked:text-white" for="notification_skillpanel_on">ON</label>
            </div>
          </div>
        </div>
      </div><!-- End スキルパネル更新通知 -->

      <div class="flex mt-8 mx-auto w-fit">
        <a class="bg-brightGray-900 border border-solid border-brightGray-900 cursor-pointer font-bold px-4 py-2 rounded select-none text-center text-white w-80 hover:filter hover:brightness-90">保存する</a>
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

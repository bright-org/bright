defmodule BrightWeb.OnboardingLive.JobPanelComponents do
  use BrightWeb, :component

  attr :carrer_group, :any
  slot :inner_block

  def accordion_group(%{career_group: %{type: :engineer}} = assigns) do
    ~H"""
    <div class="divide-y divide-gray-100">
      <div class="">
        <div
          class="flex cursor-pointer list-none items-center py-4"
          phx-click={
            JS.toggle_class("rotate-180", to: "#arrow")
            |> JS.toggle(
              to: "#jobs",
              in: {"ease-out duration-700", "opacity-0 translate-y-0", "opacity-100 translate-y-full"},
              out: {"ease-out duration-700", "pacity-100 translate-y-full", "opacity-0 translate-y-0"}
            )
          }
        >
          <p class="text-2xl mr-4"><%= @career_group.name %></p>
          <div id="arrow" class="text-secondary-500 text-2xl">
            <.icon name="hero-chevron-down-solid" class="h-5 w-5" />
          </div>
        </div>
        <div id="jobs" class="pb-4 text-secondary-500 hidden">
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </div>
    """
  end

  def accordion_group(assigns) do
    ~H"""
    <p class="text-2xl"><%= @career_group.name %></p>
    <%= render_slot(@inner_block) %>
    """
  end

  def rank_jobs(assigns) do
    ~H"""
    <div class="my-8">
      <p class="text-left text-brightGray-400 text-xl"><%= @rank_list[@rank] %></p>
      <hr class="h-[2px] bg-brightGray-50 mb-4" />
      <div class="flex flex-wrap justify-center mt-2 lg:justify-start">
        <% jobs = Map.get(@jobs, @career_field.name_en, %{}) %>
        <%= for job <- Map.get(jobs, @rank, []) do %>
          <%= if Enum.count(job.skill_panels) == 0 do %>
            <.locked_job job={job} />
          <% else %>
            <% panel_id = List.first(job.skill_panels) |> Map.get(:id, nil) %>
            <.unlocked_job
              panel_id={panel_id}
              score={Enum.find(@scores, & &1.id == panel_id)}
              current_path={@current_path}
              job={job}
              career_field={@career_field}
            />
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  def locked_job(assigns) do
    ~H"""
    <div class="border-[3px] px-2 lg:px-4 m-2 rounded w-[150px] lg:w-[340px] min-h-[100px] lg:min-h-[74px] flex flex-col bg-brightGray-50">
      <div class="flex flex-col lg:flex-row justify-between">
        <p class="flex my-2 lg:w-44 truncate text-xs text-brightGray-400 opacity-85">
          <img  class="w-[22px] h-[22px] -mt-[2px] mr-[2px]" src="/images/common/icons/biLock.svg" />
          <%= String.replace(@job.name, "🔐", "") %>
        </p>
        <button
          class="rounded border bg-white h-[28px] mt-1 px-2 text-xs hover:filter hover:brightness-[80%]"
          phx-click="request"
          phx-value-job={@job.id}
        >
          リクエストを送る
        </button>
      </div>
    </div>
    """
  end

  def unlocked_job(%{current_path: "onboardings"} = assigns) do
    ~H"""
    <div class="cursor-pointer">
      <.link navigate={"/#{@current_path}/#{@job.id}?career_field=#{@career_field.name_en}"} >
      <div
        id={"#{@career_field.name_en}-#{@panel_id}"}
        class={"px-2 lg:px-4 m-2 rounded w-[150px] lg:w-[340px] min-h-[100px] lg:min-h-[74px] flex flex-col hover:bg-[#F5FBFB] #{if is_nil(@score), do: "border-[2px]", else: "border border-brightGreen-300"}"}
      >
        <div class="flex flex-col lg:flex-row justify-between mt-2 mb-[4px]">
          <p class="text-xs lg:w-44 lg:font-bold lg:mt-1 mb-1 lg:mb-0"><%= @job.name %></p>
          <%= if is_nil(@score) do %>
            <p class="flex mb-[4px] ">
              <img src={icon_path(:none)} width="20" height="23" class="mr-2" />
              <img src={icon_path(:none)} width="20" height="23" class="mr-2" />
              <img src={icon_path(:none)} width="20" height="23" class="mr-2" />
            </p>
          <% else %>
            <p class="flex mb-[4px]">
              <%= for class <- @score.skill_classes do %>
                <% class_score = List.first(class.skill_class_scores)%>
                <%= if is_nil(class_score) do %>
                    <img src={icon_path(:none)} class="mr-2" />
                <% else %>
                    <img src={icon_path(class_score.level)}  class="mr-2" />
                <% end %>
              <% end %>
            </p>
          <% end %>
        </div>
        <hr />
        <div class="flex justify-between">
          <div class="flex gap-x-1 lg:gap-x-2 mt-2 lg:mt-1 mb-[4px]" >
            <%= for tag <- @job.career_fields do %>
              <p class={"border rounded-full px-[1px] lg:px-1 h-[20px] text-xs text-#{tag.name_en}-dark bg-#{tag.name_en}-light"}><%= tag.name_ja %></p>
            <% end %>
          </div>
        </div>
      </div>
      </.link>
    </div>
    """
  end

  def unlocked_job(%{current_path: "skill_select"} = assigns) do
    ~H"""
    <div class="cursor-pointer">
      <.link navigate={"/#{@current_path}/#{@panel_id}?career_field=#{@career_field.name_en}&class=1"} >
      <div
        id={"#{@career_field.name_en}-#{@panel_id}"}
        class={"px-2 lg:px-4 m-2 rounded w-[150px] lg:w-[340px] min-h-[140px] lg:min-h-[74px] flex flex-col hover:bg-[#F5FBFB] #{if is_nil(@score), do: "border-[2px]", else: "border border-brightGreen-300"}"}
      >
        <div class="flex flex-col lg:flex-row justify-between mt-2 mb-[4px]">
          <p class="text-xs lg:w-44 lg:font-bold lg:mt-1 mb-1 lg:mb-0"><%= @job.name %></p>
          <%= if is_nil(@score) do %>
            <p class="flex mb-[4px] ">
              <img src={icon_path(:none)} width="20" height="23" class="mr-2" />
              <img src={icon_path(:none)} width="20" height="23" class="mr-2" />
              <img src={icon_path(:none)} width="20" height="23" class="mr-2" />
            </p>
          <% else %>
            <p class="flex mb-[4px]">
              <%= for class <- @score.skill_classes do %>
                <% class_score = List.first(class.skill_class_scores)%>
                <%= if is_nil(class_score) do %>
                    <img src={icon_path(:none)} class="mr-2" />
                <% else %>
                    <img src={icon_path(class_score.level)}  class="mr-2" />
                <% end %>
              <% end %>
            </p>
          <% end %>
        </div>
        <hr />
        <div class="flex justify-between flex-col lg:flex-row">
          <div class="flex gap-x-1 lg:gap-x-2 mt-2 lg:mt-1 mb-[4px]" >
            <%= for tag <- @job.career_fields do %>
              <p class={"border rounded-full px-[1px] lg:px-1 h-[20px] text-xs text-#{tag.name_en}-dark bg-#{tag.name_en}-light"}><%= tag.name_ja %></p>
            <% end %>
          </div>
          <.link :if={!is_nil(@score)} navigate={~p"/graphs/#{@panel_id}"}>
            <button class="rounded border bg-white h-[20px] mt-1 px-2 text-xs hover:filter hover:brightness-[80%]" type="button">
              成長履歴を見る
            </button>
          </.link>
        </div>
      </div>
      </.link>
    </div>
    """
  end

  defp icon_base_path(file), do: "/images/common/icons/#{file}"
  defp icon_path(:none), do: icon_base_path("gemGray.svg")
  defp icon_path(:beginner), do: icon_base_path("jemLow.svg")
  defp icon_path(:normal), do: icon_base_path("jemMiddle.svg")
  defp icon_path(:skilled), do: icon_base_path("jemHigh.svg")
end

defmodule BrightWeb.SkillEvidenceComponents do
  @moduledoc """
  学習メモの表示に係るコンポーネント
  """

  use BrightWeb, :component

  alias Bright.Accounts
  alias Bright.UserProfiles
  alias Bright.SkillEvidences
  alias BrightWeb.PathHelper

  @doc """
  学習メモの簡易表示
  """
  attr :skill_evidence, SkillEvidences.SkillEvidence
  attr :skill_evidence_post, SkillEvidences.SkillEvidencePost
  attr :related_user_ids, :list
  attr :skill_breadcrumb, :string
  attr :current_user, Accounts.User
  attr :display_time, :boolean, default: true
  attr :anonymous, :boolean, default: true
  attr :myself, :string, default: nil
  attr :content_length, :integer, default: 200

  def skill_evidence(assigns) do
    ~H"""
    <%# アイコン表示 %>
    <div class="flex-none text-center pt-4 mx-2">
      <% my_post? = @current_user.id == @skill_evidence_post.user_id %>
      <% anonymous? = @anonymous || @skill_evidence_post.user_id not in @related_user_ids %>

      <%= if my_post? do %>
        <img class="h-10 w-10 rounded-full" src={icon_file_path(@current_user, false)} />
      <% else %>
        <.link navigate={PathHelper.mypage_path(@skill_evidence_post.user, anonymous?)}>
          <img class="h-10 w-10 rounded-full" src={icon_file_path(@skill_evidence_post.user, anonymous?)} />
        </.link>
      <% end %>
    </div>

    <%# 投稿表示 %>
    <div class="grow flex flex-col gap-y-2 mx-2">
      <div class="text-xs flex justify-between">
        <p class="font-bold"><%= @skill_breadcrumb %></p>
        <div
          :if={@display_time}
          id={"timestamp-#{@skill_evidence_post.id}"}
          phx-hook="LocalTime"
          phx-update="ignore"
          data-iso={NaiveDateTime.to_iso8601(@skill_evidence_post.inserted_at)}
          >
          <p class="hidden lg:block" data-local-time="%x %H:%M"></p>
        </div>
      </div>
      <div class="markdown-body break-all">
        <%= raw content_to_html_shortly(@skill_evidence_post, @content_length) %>
      </div>
      <nav class="flex items-center gap-x-4">
        <button
          class="link-evidence"
          phx-click="edit_skill_evidence"
          phx-target={@myself}
          phx-value-id={@skill_evidence.id}
        >
          <img src="/images/common/icons/skillEvidenceActive.svg">
        </button>
        <p :if={@skill_evidence.progress == :help} class="border rounded-full p-1 text-xs text-gray-800 bg-gray-50">ヘルプ</p>
      </nav>
    </div>
    """
  end

  defp icon_file_path(_user, true), do: UserProfiles.icon_url(nil)

  defp icon_file_path(user, _anonymous) do
    UserProfiles.icon_url(user.user_profile.icon_file_path)
  end

  defp content_to_html_shortly(skill_evidence, length) do
    # truncateがマークダウン書式途中(巨大なコードブロック等)になる可能性はある
    skill_evidence.content
    |> SkillEvidences.truncate_post_content(length)
    |> SkillEvidences.make_content_as_html()
  end
end

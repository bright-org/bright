defmodule BrightWeb.GuideMessageComponents do
  @moduledoc """
  ガイドメッセージを集めたコンポーネント
  """

  use BrightWeb, :component

  @doc """
  スキル入力解説メッセージ
  """
  def enter_skills_help_message(%{reference_from: "button"} = assigns) do
    # 現状はスキル入力前メッセージと同様
    ~H"""
    <.first_skills_edit_message />
    """
  end

  def enter_skills_help_message(%{reference_from: "modal"} = assigns) do
    ~H"""
    <p>スキル入力は、途中保存可能でいつでも変更できます。</p>
    <.score_mark_description />
    <.shortcut_key_description />
    """
  end

  @doc """
  スキル入力前メッセージ
  """
  def first_skills_edit_message(assigns) do
    ~H"""
    <p>
      <span class="font-bold">まずは「スキル入力する」ボタンをクリック</span>してスキル入力を始めてください。
    </p>
    <p>スキル入力は、途中保存可能でいつでも変更できます。</p>
    <.score_mark_description />
    <.shortcut_key_description />
    <.evidence_introduction_description />
    """
  end

  @doc """
  スキル入力後メッセージ（初回のみ）
  """
  def first_submit_in_overall_message(assigns) do
    ~H"""
    <div>
      <p>スキル入力完了おめでとうございます！</p>
      <p class="mt-4">
        <span class={[score_mark_class(:high, :green), "inline-block align-middle mr-1"]} /><span class="align-middle">が40％より下は「見習い」、40％以上で「平均」、60％以上で「ベテラン」となります。</span>
      </p>
      <p class="mt-2">
        スキル入力後は「成長パネル」メニューで現在のスキルレベルを確認できます。
      </p>
      <p>
        また、3ヶ月区切りでスキルレベルを集計するので、スキルの成長も体感できます。
      </p>
      <div class="mt-2 max-w-[400px]">
        <img src="/images/sample_groth_graph.png" alt="成長パネル" />
      </div>
      <.evidence_introduction_description />
    </div>
    """
  end

  @doc """
  求職案内メッセージ
  """
  def prompt_job_searching_message(assigns) do
    ~H"""
    <div id="job_searching_message" class="flex fixed lg:absolute items-center right-4 top-12 lg:-top-16 w-fit px-5 lg:px-0 z-10">
      <div class="bg-designer-dazzle flex leading-normal px-4 py-2 rounded text-xs w-fit">
        <p>上記の求職設定を行うと、スキル検索であなたのスキルを必要とするプロジェクト（副業含む）から声がかかるようになります。</p>
      </div>
      <div id="arrow-to-job-searching" class="arrow ml-1"></div>
    </div>
    """
  end

  defp score_mark_description(assigns) do
    ~H"""
    <ul class="my-2">
      <li class="flex items-center">
        <span class={[score_mark_class(:high, :green), "inline-block mr-1"]} />
        実務経験がある、もしくは依頼されたら短期間で実行できる
      </li>
      <li class="flex items-center">
        <span class={[score_mark_class(:middle, :green), "inline-block mr-1"]} />
        知識はあるが、実務経験が浅く、自信が無い（調査が必要）
      </li>
      <li class="flex items-center">
        <span class={[score_mark_class(:low, :green), "inline-block mr-1"]} />
        知識や実務経験が無い
      </li>
    </ul>
    """
  end

  defp shortcut_key_description(assigns) do
    ~H"""
    <div class="hidden lg:block">
      <p class="flex flex-wrap items-center">
        1キーを押すと
        <span class={[score_mark_class(:high, :green), "inline-block mx-1"]} />
        が付き、2キーを押すと
        <span class={[score_mark_class(:middle, :green), "inline-block mx-1"]} />
        、3キーで
        <span class={[score_mark_class(:low, :green), "inline-block mx-1"]} />
        が付くので、
      </p>
      <p>マウス無しのキーボード操作だけで快適にスキル入力できます。</p>
    </div>
    """
  end

  defp evidence_introduction_description(assigns) do
    ~H"""
    <p class="mt-4">
      なお、各スキルを学んだ記録やメモを残したい場合は、<span class="text-brightGreen-600"><img src="/images/common/icons/skillEvidence.svg" class="inline-block"></span>から、メモを入力することが<br class="hidden lg:inline">できます。（βリリースでは他のチームメンバーにヘルプを出したりできます）
    </p>
    """
  end

  defp score_mark_class(mark, color) do
    BrightWeb.SkillPanelLive.SkillPanelComponents.score_mark_class(mark, color)
  end
end

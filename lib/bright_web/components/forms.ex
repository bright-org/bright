defmodule BrightWeb.Forms do
  @moduledoc """
  formまわりの共通コンポーネント
  """

  use BrightWeb, :html

  alias BrightWeb.BrightCoreComponents, as: BrightCore

  embed_templates "forms/*"

  @doc """
  無料トライアル申し込みフォーム
  """

  attr :id, :string, required: true
  attr :form, :any, required: true, doc: "the datastructure for the form"
  attr :phx_submit, :string
  attr :phx_change, :string

  def free_trial_form(assigns)
end

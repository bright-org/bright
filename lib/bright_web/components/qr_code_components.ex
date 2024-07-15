defmodule BrightWeb.QrCodeComponents do
  @moduledoc """
  QRコードコンポーネント
  """
  use Phoenix.Component
  import BrightWeb.CoreComponents, only: [icon: 1]
  import BrightWeb.BrightModalComponents, only: [bright_modal: 1]

  @doc """
  QRコードのアイコンボタン
  """
  attr :rest, :global

  def qr_icon_button(assigns) do
    ~H"""
    <button class="border border-brightGray-200 border-b rounded-md" {@rest}>
      <.icon name="hero-qr-code" class="w-7 h-7" />
    </button>
    """
  end

  @doc """
  QRコード表示用モーダル
  """

  attr :qr_code_url, :string, required: true
  attr :open_qr_code_modal, :boolean, required: true
  attr :on_cancel, :any, required: true

  def qr_code_modal(assigns) do
    ~H"""
    <.bright_modal
      :if={@open_qr_code_modal}
      id="qr-code-modal"
      on_cancel={@on_cancel}
      show
    >
      <div class="flex justify-center items-center">
        <.qr_code_image url={@qr_code_url} />
      </div>
    </.bright_modal>
    """
  end

  defp qr_code_image(assigns) do
    ~H"""
      <img src={qr_code_image_src(@url)} alt="二次元バーコード" />
    """
  end

  defp qr_code_image_src(url) do
    EQRCode.encode(url)
    |> EQRCode.png()
    |> Base.encode64()
    |> then(fn base64 -> "data:image/png;base64,#{base64}" end)
  end
end

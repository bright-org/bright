defmodule BrightWeb.QrCodeComponents do
  @moduledoc """
  QRコードコンポーネント
  """
  use Phoenix.Component

  @doc """
  QRコードのボタン
  """

  attr :qr_code_url, :string, required: true
  attr :rest, :global

  def qr_code_image(assigns) do
    ~H"""
      <img src={qr_code_image_src(@qr_code_url)} alt="二次元バーコード" {@rest} />
    """
  end

  defp qr_code_image_src(url) do
    EQRCode.encode(url)
    |> EQRCode.png()
    |> Base.encode64()
    |> then(fn base64 -> "data:image/png;base64,#{base64}" end)
  end
end

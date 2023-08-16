defmodule Bright.Utils.Aes.Aes128 do
  @moduledoc """
  Aes128
  """

  # 参考にしたURL
  # https://elixirforum.com/t/help-with-crypto-module-crypto-one-time-method-argumenterror-argument-error-issue/38129

  # TODO: @secret_keyを外部指定にすること
  # secret_keyはblock_sizeで文字列を指定すること
  @secret_key "1234567890123456"
  @block_size 16

  @doc """
  Encrypt with Aes128

  ## Examples
      iex> Bright.Utils.Aes.Aes128.encrypt(plaintext)
      "SRXHIrl3aAPXJcED2+rx4byNh6y1F/Vy9CNWLQ1Fr0Q="
  """
  def encrypt(plaintext) do
    # ivとは初期化ベクトルの意味で、毎回内容を変えることにより暗号解読をしにくくする
    # 16byte単位で処理できるようにする
    # 出力形式はvi + 暗号化文字列をBase64にする
    iv = :crypto.strong_rand_bytes(@block_size)
    plaintext = pad(plaintext, @block_size)
    encrypted_text = :crypto.crypto_one_time(:aes_128_cbc, @secret_key, iv, plaintext, true)
    encrypted_text = iv <> encrypted_text
    :base64.encode(encrypted_text)
  end

  @doc """
  Decrypt with Aes128

  ## Examples
      iex> Bright.Utils.Aes.Aes128.decrypt(ciphertext)
      "hoge"

  """
  def decrypt(ciphertext) do
    # Base64文字列を復号化する
    # 先頭の16バイトのviとそれ以降の暗号文字列に分割
    # ivとsecret_keyと暗号文字列を元に復号する
    # 16byte単位で処理できるようにする
    ciphertext = :base64.decode(ciphertext)
    <<iv::binary-16, ciphertext::binary>> = ciphertext
    decrypted_text = :crypto.crypto_one_time(:aes_128_cbc, @secret_key, iv, ciphertext, false)
    unpad(decrypted_text)
  end

  defp unpad(data) do
    to_remove = :binary.last(data)
    :binary.part(data, 0, byte_size(data) - to_remove)
  end

  defp pad(data, block_size) do
    to_add = block_size - rem(byte_size(data), block_size)
    data <> :binary.copy(<<to_add>>, to_add)
  end
end

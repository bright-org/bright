defmodule Bright.Exceptions.ForbiddenResourceError do
  @moduledoc """
  「チームの所属していないと参照できない」などリソースに対するアクセス権がない場合の汎用エラー
  HTTP的には403 Forbiddenだが、エラー理由を曖昧にする為に404扱いとする
  """
  defexception message: "Forbidden resource error", plug_status: 404
end

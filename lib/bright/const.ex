defmodule Bright.Const do
  @moduledoc """
  # Bright 内で使用したい定数を定義するモジュール
  """

  # SendGrid で1リクエストで一括送信可能な最大のメール件数は 1000 件
  # NOTE: https://sendgrid.kke.co.jp/docs/API_Reference/Web_API_v3/Mail/index.html?_gl=1*1sf2pmz*_ga*MTE5MjM3OTk0OS4xNzA1NzI5Nzc1*_ga_JL4V7PSVHH*MTcwNTcyOTc3NC4xLjEuMTcwNTcyOTk2My4wLjAuMA..*_ga_NFRNW0FC62*MTcwNTcyOTc3NC4xLjEuMTcwNTcyOTk2My4wLjAuMA..#-Limitations
  def sendgrid_max_deliver_size, do: 1000
end

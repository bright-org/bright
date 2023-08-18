defmodule Bright.Exceptions.NotFoundError do
  defexception message: "Not Found", plug_status: 404
end

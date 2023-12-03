defimpl Plug.Exception, for: Ecto.Query.CastError do
  def status(_exception), do: 404
  def actions(_exception), do: []
end

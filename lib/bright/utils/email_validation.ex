defmodule Bright.Utils.EmailValidation do
  @moduledoc """
  custom validator for email
  """

  import Ecto.Changeset

  def validate(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(
      :email,
      ~r/^(?>[-[:alpha:][:alnum:]+_!"'#$%^&*{}\/=?`|~](?:\.?[-[:alpha:][:alnum:]+_!"'#$%^&*{}\/=?`|~]){0,63})@(?=.{1,255}$)(?:(?=[^.]{1,63}(?:\.|$))(?!.*?--.*$)[[:alnum:]](?:(?:[[:alnum:]]|-){0,61}[[:alnum:]])?\.)*(?=[^.]{1,63}(?:\.|$))(?!.*?--.*$)[[:alnum:]](?:(?:[[:alnum:]]|-){0,61}[[:alnum:]])?\.[[:alpha:]]{1,64}$/i
    )
    |> validate_length(:email, max: 160)
  end
end

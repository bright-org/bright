# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Bright.Repo.insert!(%Bright.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
Bright.Seeds.Job.delete()
Bright.Seeds.CareerField.delete()
Bright.Seeds.CareerField.insert()
Bright.Seeds.Job.insert()

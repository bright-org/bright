defmodule Bright.BatchesTest do
  use ExUnit.Case, async: true
  use ExUnit.Parameterized
  import Mock

  alias Bright.Batches

  describe "update_skill_panels/0" do
    alias Bright.Batches.UpdateSkillPanels

    test_with_params "calls UpdateSkillPanels.call/2",
                     fn today, dry_run ->
                       now = DateTime.new!(today, ~T[00:00:00], "Asia/Tokyo")

                       with_mocks([
                         {DateTime, [:passthrough], [now!: fn "Asia/Tokyo" -> now end]},
                         {UpdateSkillPanels, [:passthrough],
                          [call: fn _locked_date, _dry_run -> nil end]}
                       ]) do
                         Batches.update_skill_panels()

                         assert_called(UpdateSkillPanels.call(today, dry_run))
                       end
                     end do
      # NOTE: dry-runの判定には年を使わないため任意の値でOK
      year = :random.uniform(10_000)

      [
        {Date.new!(year, 1, 1), false},
        {Date.new!(year, 1, 2), true},
        {Date.new!(year, 3, 31), true},
        {Date.new!(year, 4, 1), false},
        {Date.new!(year, 4, 2), true},
        {Date.new!(year, 6, 30), true},
        {Date.new!(year, 7, 1), false},
        {Date.new!(year, 7, 2), true},
        {Date.new!(year, 9, 30), true},
        {Date.new!(year, 10, 1), false},
        {Date.new!(year, 10, 2), true},
        {Date.new!(year, 12, 31), true}
      ]
    end
  end
end

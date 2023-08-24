defmodule Bright.SearchesTest do
  use Bright.DataCase

  alias Bright.Searches

  import Bright.Factory

  describe "skill_search/3" do
    setup do
      user_1 = insert(:user)
      user_2 = insert(:user)

      # キャリアフィールドからスキルクラスまでの用意
      career_field = insert(:career_field, name_en: "engineer")
      job = insert(:job)
      insert(:career_field_job, career_field: career_field, job: job)

      skill_panel_1 = insert(:skill_panel)
      insert(:job_skill_panel, job: job, skill_panel: skill_panel_1)
      skill_class_1 = insert(:skill_class, skill_panel: skill_panel_1, class: 1)
      skill_class_2 = insert(:skill_class, skill_panel: skill_panel_1, class: 2)

      skill_panel_2 = insert(:skill_panel)
      insert(:job_skill_panel, job: job, skill_panel: skill_panel_2)
      skill_class_3 = insert(:skill_class, skill_panel: skill_panel_2, class: 1)

      # 保有スキルパネルとスキルクラススコアの用意
      insert(:user_skill_panel, user: user_1, skill_panel: skill_panel_1)
      insert(:user_skill_panel, user: user_2, skill_panel: skill_panel_1)
      insert(:user_skill_panel, user: user_2, skill_panel: skill_panel_2)
      insert(:skill_class_score, user: user_1, skill_class: skill_class_1, level: :normal)
      insert(:skill_class_score, user: user_2, skill_class: skill_class_1, level: :skilled)
      insert(:skill_class_score, user: user_2, skill_class: skill_class_2, level: :normal)
      insert(:skill_class_score, user: user_2, skill_class: skill_class_3, level: :normal)

      %{
        user_1: user_1,
        user_2: user_2,
        skill_panel_1: skill_panel_1,
        skill_panel_2: skill_panel_2
      }
    end

    test "only job_searching true user", %{user_1: %{id: id} = user_1, user_2: user_2} do
      insert(:user_job_profile, user: user_1)
      insert(:user_job_profile, user: user_2, job_searching: false)
      user = insert(:user)
      query = {[{:job_searching, true}], %{}, []}

      assert [%{id: ^id}] = Searches.skill_search(user.id, query)
    end

    test "greater than equal pj_start", %{user_1: %{id: id} = user_1, user_2: user_2} do
      insert(:user_job_profile, user: user_1, availability_date: ~D[2023-09-01])
      insert(:user_job_profile, user: user_2, availability_date: ~D[2023-08-25])
      user = insert(:user)
      query = {[{:job_searching, true}], %{pj_start: "2023-09-01"}, []}

      assert [%{id: ^id}] = Searches.skill_search(user.id, query)
    end

    test "less than equal pj_start", %{user_1: %{id: id} = user_1, user_2: user_2} do
      insert(:user_job_profile, user: user_1, availability_date: ~D[2023-08-25])
      insert(:user_job_profile, user: user_2, availability_date: ~D[2023-09-01])
      user = insert(:user)
      query = {[{:job_searching, true}], %{pj_end: "2023-08-25"}, []}

      assert [%{id: ^id}] = Searches.skill_search(user.id, query)
    end

    test "between pj_start and pj_end", %{user_1: %{id: id} = user_1, user_2: user_2} do
      insert(:user_job_profile, user: user_1, availability_date: ~D[2023-08-25])
      insert(:user_job_profile, user: user_2, availability_date: ~D[2023-09-01])
      user = insert(:user)
      query = {[{:job_searching, true}], %{pj_start: "2023-08-25", pj_end: "2023-08-31"}, []}

      assert [%{id: ^id}] = Searches.skill_search(user.id, query)
    end

    test "less than equal desired_income", %{user_1: %{id: id} = user_1, user_2: user_2} do
      insert(:user_job_profile, user: user_1, desired_income: 800)
      insert(:user_job_profile, user: user_2, desired_income: 1000)
      user = insert(:user)
      query = {[{:job_searching, true}], %{desired_income: 800}, []}

      assert [%{id: ^id}] = Searches.skill_search(user.id, query)
    end

    test "only wish change_job", %{user_1: %{id: id} = user_1, user_2: user_2} do
      insert(:user_job_profile, user: user_1, wish_change_job: true)
      insert(:user_job_profile, user: user_2, wish_change_job: false)
      user = insert(:user)
      query = {[{:job_searching, true}, {:wish_change_job, true}], %{}, []}

      assert [%{id: ^id}] = Searches.skill_search(user.id, query)
    end

    test "only wish employed", %{user_1: %{id: id} = user_1, user_2: user_2} do
      insert(:user_job_profile, user: user_1, wish_employed: true)
      insert(:user_job_profile, user: user_2, wish_employed: false)
      user = insert(:user)
      query = {[{:job_searching, true}, {:wish_employed, true}], %{}, []}

      assert [%{id: ^id}] = Searches.skill_search(user.id, query)
    end

    test "only wish freelance", %{user_1: %{id: id} = user_1, user_2: user_2} do
      insert(:user_job_profile, user: user_1, wish_freelance: true)
      insert(:user_job_profile, user: user_2, wish_freelance: false)
      user = insert(:user)
      query = {[{:job_searching, true}, {:wish_freelance, true}], %{}, []}

      assert [%{id: ^id}] = Searches.skill_search(user.id, query)
    end

    test "only wish side_job", %{user_1: %{id: id} = user_1, user_2: user_2} do
      insert(:user_job_profile, user: user_1, wish_side_job: true)
      insert(:user_job_profile, user: user_2, wish_side_job: false)
      user = insert(:user)
      query = {[{:job_searching, true}, {:wish_side_job, true}], %{}, []}

      assert [%{id: ^id}] = Searches.skill_search(user.id, query)
    end

    test "only office work", %{user_1: %{id: id} = user_1, user_2: user_2} do
      insert(:user_job_profile, user: user_1, office_work: true)
      insert(:user_job_profile, user: user_2, office_work: false)
      user = insert(:user)
      query = {[{:job_searching, true}, {:office_work, true}], %{}, []}

      assert [%{id: ^id}] = Searches.skill_search(user.id, query)
    end

    test "only office work and work Tokyo", %{user_1: %{id: id} = user_1, user_2: user_2} do
      insert(:user_job_profile, user: user_1, office_work: true, office_pref: "東京都")
      insert(:user_job_profile, user: user_2, office_work: true, office_pref: "福岡県")
      user = insert(:user)

      query = {[{:job_searching, true}, {:office_work, true}, {:office_pref, "東京都"}], %{}, []}

      assert [%{id: ^id}] = Searches.skill_search(user.id, query)
    end

    test "only office work and 160h/m orver", %{user_1: %{id: id} = user_1, user_2: user_2} do
      insert(:user_job_profile, user: user_1, office_work: true, office_working_hours: "月160h以上")
      insert(:user_job_profile, user: user_2, office_work: true, office_working_hours: "月79h以下")
      user = insert(:user)

      query =
        {[{:job_searching, true}, {:office_work, true}, {:office_working_hours, "月160h以上"}], %{},
         []}

      assert [%{id: ^id}] = Searches.skill_search(user.id, query)
    end

    test "only office work and work holiday", %{user_1: %{id: id} = user_1, user_2: user_2} do
      insert(:user_job_profile, user: user_1, office_work: true, office_work_holidays: true)
      insert(:user_job_profile, user: user_2, office_work: true, office_work_holidays: false)
      user = insert(:user)

      query =
        {[
           {:job_searching, true},
           {:office_work, true},
           {:office_work_holidays, true}
         ], %{}, []}

      assert [%{id: ^id}] = Searches.skill_search(user.id, query)
    end

    test "only remote work", %{user_1: %{id: id} = user_1, user_2: user_2} do
      insert(:user_job_profile, user: user_1, remote_work: true)
      insert(:user_job_profile, user: user_2, remote_work: false)
      user = insert(:user)
      query = {[{:job_searching, true}, {:remote_work, true}], %{}, []}

      assert [%{id: ^id}] = Searches.skill_search(user.id, query)
    end

    test "only remote work and 160h/m orver", %{user_1: %{id: id} = user_1, user_2: user_2} do
      insert(:user_job_profile, user: user_1, remote_work: true, remote_working_hours: "月160h以上")
      insert(:user_job_profile, user: user_2, remote_work: true, remote_working_hours: "月79h以下")

      user = insert(:user)

      query =
        {[{:job_searching, true}, {:remote_work, true}, {:remote_working_hours, "月160h以上"}], %{},
         []}

      assert [%{id: ^id}] = Searches.skill_search(user.id, query)
    end

    test "only remote work and work holiday", %{user_1: %{id: id} = user_1, user_2: user_2} do
      insert(:user_job_profile, user: user_1, remote_work: true, remote_work_holidays: true)
      insert(:user_job_profile, user: user_2, remote_work: true, remote_work_holidays: false)
      user = insert(:user)

      query =
        {[
           {:job_searching, true},
           {:remote_work, true},
           {:remote_work_holidays, true}
         ], %{}, []}

      assert [%{id: ^id}] = Searches.skill_search(user.id, query)
    end

    test "having skill_panel_2", %{
      user_1: user_1,
      user_2: %{id: id} = user_2,
      skill_panel_2: panel
    } do
      insert(:user_job_profile, user: user_1)
      insert(:user_job_profile, user: user_2)
      user = insert(:user)

      query = {[{:job_searching, true}], %{}, [%{skill_panel: panel.id}]}

      assert [%{id: ^id}] = Searches.skill_search(user.id, query)
    end

    test "having skill_panel 1 & 2", %{
      user_1: user_1,
      user_2: %{id: id} = user_2,
      skill_panel_1: panel_1,
      skill_panel_2: panel_2
    } do
      insert(:user_job_profile, user: user_1)
      insert(:user_job_profile, user: user_2)
      user = insert(:user)

      query =
        {[{:job_searching, true}], %{}, [%{skill_panel: panel_1.id}, %{skill_panel: panel_2.id}]}

      assert [%{id: ^id}] = Searches.skill_search(user.id, query)
    end

    test "having skill_panel 1 and open class 2", %{
      user_1: user_1,
      user_2: %{id: id} = user_2,
      skill_panel_1: panel_1
    } do
      insert(:user_job_profile, user: user_1)
      insert(:user_job_profile, user: user_2)
      user = insert(:user)

      query = {[{:job_searching, true}], %{}, [%{skill_panel: panel_1.id, class: 2}]}
      assert [%{id: ^id}] = Searches.skill_search(user.id, query)
    end

    test "having skill_panel 1 and open class 1 and skilled", %{
      user_1: user_1,
      user_2: %{id: id} = user_2,
      skill_panel_1: panel_1
    } do
      insert(:user_job_profile, user: user_1)
      insert(:user_job_profile, user: user_2)
      user = insert(:user)

      query =
        {[{:job_searching, true}], %{}, [%{skill_panel: panel_1.id, class: 1, level: "skilled"}]}

      assert [%{id: ^id}] = Searches.skill_search(user.id, query)
    end
  end
end

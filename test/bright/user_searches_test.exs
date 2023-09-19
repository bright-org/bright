defmodule Bright.UserSearchesTest do
  use Bright.DataCase

  alias Bright.UserSearches

  import Bright.Factory

  describe "search_users_by_job_profile_and_skill_score/3" do
    setup do
      user_1 = insert(:user)
      user_2 = insert(:user)
      user_3 = insert(:user)

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
      insert(:user_skill_panel, user: user_3, skill_panel: skill_panel_1)

      insert(:skill_class_score,
        user: user_1,
        skill_class: skill_class_1,
        level: :normal,
        percentage: 40
      )

      insert(:skill_class_score,
        user: user_2,
        skill_class: skill_class_1,
        level: :skilled,
        percentage: 60
      )

      insert(:skill_class_score, user: user_2, skill_class: skill_class_2, level: :normal)
      insert(:skill_class_score, user: user_2, skill_class: skill_class_3, level: :normal)

      insert(:skill_class_score,
        user: user_3,
        skill_class: skill_class_1,
        level: :skilled,
        percentage: 60
      )

      %{
        user_1: user_1,
        user_2: user_2,
        user_3: user_3,
        skill_panel_1: skill_panel_1,
        skill_panel_2: skill_panel_2,
        skill_class_1: skill_class_1
      }
    end

    test "only job_searching true user", %{
      user_1: %{id: id} = user_1,
      user_2: user_2
    } do
      insert(:user_job_profile, user: user_1)
      insert(:user_job_profile, user: user_2, job_searching: false)

      query = {[{:job_searching, true}], %{}, []}

      assert %{entries: [%{id: ^id}]} =
               UserSearches.search_users_by_job_profile_and_skill_score(query)
    end

    test "reject includes exlude_user_ids user", %{user_1: %{id: id} = user_1, user_2: user_2} do
      insert(:user_job_profile, user: user_1)
      insert(:user_job_profile, user: user_2)

      query = {[{:job_searching, true}], %{}, []}

      assert %{entries: [%{id: ^id}]} =
               UserSearches.search_users_by_job_profile_and_skill_score(query,
                 exclude_user_ids: [user_2.id]
               )
    end

    test "sort_by last_update_desc and last_update_asc", %{
      user_1: %{id: id_1} = user_1,
      user_2: %{id: id_2} = user_2,
      skill_class_1: skill_class
    } do
      skill_unit = insert(:skill_unit, skill_classes: [skill_class])
      skill_category = insert(:skill_category, skill_unit: skill_unit)
      skill = insert(:skill, skill_category: skill_category)
      insert(:user_job_profile, user: user_1)
      insert(:user_job_profile, user: user_2)
      insert(:skill_score, user: user_1, updated_at: ~N[2023-01-01 00:00:00], skill: skill)
      insert(:skill_score, user: user_2, updated_at: ~N[2023-01-02 00:00:00], skill: skill)

      query = {[{:job_searching, true}], %{}, []}

      assert %{entries: [%{id: ^id_2}, %{id: ^id_1}]} =
               UserSearches.search_users_by_job_profile_and_skill_score(query,
                 sort: :last_updated_desc
               )

      assert %{entries: [%{id: ^id_1}, %{id: ^id_2}]} =
               UserSearches.search_users_by_job_profile_and_skill_score(query,
                 sort: :last_updated_asc
               )
    end

    test "sort_by income_desc and income_asc", %{
      user_1: %{id: id_1} = user_1,
      user_2: %{id: id_2} = user_2
    } do
      insert(:user_job_profile, user: user_1, desired_income: 500)
      insert(:user_job_profile, user: user_2, desired_income: 600)

      query = {[{:job_searching, true}], %{}, []}

      assert %{entries: [%{id: ^id_2}, %{id: ^id_1}]} =
               UserSearches.search_users_by_job_profile_and_skill_score(query,
                 sort: :income_desc
               )

      assert %{entries: [%{id: ^id_1}, %{id: ^id_2}]} =
               UserSearches.search_users_by_job_profile_and_skill_score(query,
                 sort: :income_asc
               )
    end

    test "sort_by income_desc and income_asc null_last", %{
      user_1: %{id: id_1} = user_1,
      user_2: %{id: id_2} = user_2
    } do
      insert(:user_job_profile, user: user_1, desired_income: nil)
      insert(:user_job_profile, user: user_2, desired_income: 600)

      query = {[{:job_searching, true}], %{}, []}

      assert %{entries: [%{id: ^id_2}, %{id: ^id_1}]} =
               UserSearches.search_users_by_job_profile_and_skill_score(query,
                 sort: :income_desc
               )

      assert %{entries: [%{id: ^id_2}, %{id: ^id_1}]} =
               UserSearches.search_users_by_job_profile_and_skill_score(query,
                 sort: :income_asc
               )
    end

    test "sort_by score_desc and score_asc", %{
      user_1: %{id: id_1} = user_1,
      user_2: %{id: id_2} = user_2,
      skill_panel_1: panel_1
    } do
      insert(:user_job_profile, user: user_1)
      insert(:user_job_profile, user: user_2)

      query = {[{:job_searching, true}], %{}, [%{skill_panel: panel_1.id, class: 1}]}

      assert %{entries: [%{id: ^id_2}, %{id: ^id_1}]} =
               UserSearches.search_users_by_job_profile_and_skill_score(query,
                 sort: :score_desc
               )

      assert %{entries: [%{id: ^id_1}, %{id: ^id_2}]} =
               UserSearches.search_users_by_job_profile_and_skill_score(query,
                 sort: :score_asc
               )
    end

    test "pagination over 5 users", %{skill_class_1: skill_class} do
      insert_list(6, :user,
        user_job_profile: params_with_assocs(:user_job_profile),
        skill_class_scores: [params_with_assocs(:skill_class_score, skill_class: skill_class)]
      )

      query = {[{:job_searching, true}], %{}, []}

      assert %{total_pages: 2, page_number: 1, total_entries: 6} =
               UserSearches.search_users_by_job_profile_and_skill_score(query)
    end

    test "pagination next page", %{skill_class_1: skill_class} do
      insert_list(6, :user,
        user_job_profile: params_with_assocs(:user_job_profile),
        skill_class_scores: [params_with_assocs(:skill_class_score, skill_class: skill_class)]
      )

      query = {[{:job_searching, true}], %{}, []}

      assert %{total_pages: 2, page_number: 2, total_entries: 6, entries: entries} =
               UserSearches.search_users_by_job_profile_and_skill_score(query, page: 2)

      assert length(entries) == 1
    end

    test "less than equal desired_income or nil", %{
      user_1: %{id: id_1} = user_1,
      user_2: user_2,
      user_3: %{id: id_3} = user_3
    } do
      insert(:user_job_profile, user: user_1, desired_income: 800)
      insert(:user_job_profile, user: user_2, desired_income: 1000)
      insert(:user_job_profile, user: user_3, desired_income: nil)

      query = {[{:job_searching, true}], %{desired_income: 800}, []}

      assert %{entries: [%{id: ^id_1}, %{id: ^id_3}]} =
               UserSearches.search_users_by_job_profile_and_skill_score(query)
    end

    test "only wish change_job", %{user_1: %{id: id} = user_1, user_2: user_2} do
      insert(:user_job_profile, user: user_1, wish_change_job: true)
      insert(:user_job_profile, user: user_2, wish_change_job: false)

      query = {[{:job_searching, true}, {:wish_change_job, true}], %{}, []}

      assert %{entries: [%{id: ^id}]} =
               UserSearches.search_users_by_job_profile_and_skill_score(query)
    end

    test "only wish employed", %{user_1: %{id: id} = user_1, user_2: user_2} do
      insert(:user_job_profile, user: user_1, wish_employed: true)
      insert(:user_job_profile, user: user_2, wish_employed: false)

      query = {[{:job_searching, true}, {:wish_employed, true}], %{}, []}

      assert %{entries: [%{id: ^id}]} =
               UserSearches.search_users_by_job_profile_and_skill_score(query)
    end

    test "only wish freelance", %{user_1: %{id: id} = user_1, user_2: user_2} do
      insert(:user_job_profile, user: user_1, wish_freelance: true)
      insert(:user_job_profile, user: user_2, wish_freelance: false)

      query = {[{:job_searching, true}, {:wish_freelance, true}], %{}, []}

      assert %{entries: [%{id: ^id}]} =
               UserSearches.search_users_by_job_profile_and_skill_score(query)
    end

    test "only wish side_job", %{user_1: %{id: id} = user_1, user_2: user_2} do
      insert(:user_job_profile, user: user_1, wish_side_job: true)
      insert(:user_job_profile, user: user_2, wish_side_job: false)

      query = {[{:job_searching, true}, {:wish_side_job, true}], %{}, []}

      assert %{entries: [%{id: ^id}]} =
               UserSearches.search_users_by_job_profile_and_skill_score(query)
    end

    test "only office work", %{user_1: %{id: id} = user_1, user_2: user_2} do
      insert(:user_job_profile, user: user_1, office_work: true)
      insert(:user_job_profile, user: user_2, office_work: false)

      query = {[{:job_searching, true}, {:office_work, true}], %{}, []}

      assert %{entries: [%{id: ^id}]} =
               UserSearches.search_users_by_job_profile_and_skill_score(query)
    end

    test "only office work and work Tokyo or nil", %{
      user_1: %{id: id_1} = user_1,
      user_2: user_2,
      user_3: %{id: id_3} = user_3
    } do
      insert(:user_job_profile, user: user_1, office_work: true, office_pref: "東京都")
      insert(:user_job_profile, user: user_2, office_work: true, office_pref: "福岡県")
      insert(:user_job_profile, user: user_3, office_work: true, office_pref: nil)

      query = {[{:job_searching, true}, {:office_work, true}, {:office_pref, "東京都"}], %{}, []}

      assert %{entries: [%{id: ^id_1}, %{id: ^id_3}]} =
               UserSearches.search_users_by_job_profile_and_skill_score(query)
    end

    test "only office work and 160h/m orver or nil", %{
      user_1: %{id: id_1} = user_1,
      user_2: user_2,
      user_3: %{id: id_3} = user_3
    } do
      insert(:user_job_profile, user: user_1, office_work: true, office_working_hours: "月160h以上")
      insert(:user_job_profile, user: user_2, office_work: true, office_working_hours: "月79h以下")
      insert(:user_job_profile, user: user_3, office_work: true, office_working_hours: nil)

      query =
        {[{:job_searching, true}, {:office_work, true}, {:office_working_hours, "月160h以上"}], %{},
         []}

      assert %{entries: [%{id: ^id_1}, %{id: ^id_3}]} =
               UserSearches.search_users_by_job_profile_and_skill_score(query)
    end

    test "only office work and work holiday", %{
      user_1: %{id: id} = user_1,
      user_2: user_2
    } do
      insert(:user_job_profile, user: user_1, office_work: true, office_work_holidays: true)
      insert(:user_job_profile, user: user_2, office_work: true, office_work_holidays: false)

      query =
        {[
           {:job_searching, true},
           {:office_work, true},
           {:office_work_holidays, true}
         ], %{}, []}

      assert %{entries: [%{id: ^id}]} =
               UserSearches.search_users_by_job_profile_and_skill_score(query)
    end

    test "only remote work", %{user_1: %{id: id} = user_1, user_2: user_2} do
      insert(:user_job_profile, user: user_1, remote_work: true)
      insert(:user_job_profile, user: user_2, remote_work: false)

      query = {[{:job_searching, true}, {:remote_work, true}], %{}, []}

      assert %{entries: [%{id: ^id}]} =
               UserSearches.search_users_by_job_profile_and_skill_score(query)
    end

    test "only remote work and 160h/m orver or nil", %{
      user_1: %{id: id_1} = user_1,
      user_2: user_2,
      user_3: %{id: id_3} = user_3
    } do
      insert(:user_job_profile, user: user_1, remote_work: true, remote_working_hours: "月160h以上")
      insert(:user_job_profile, user: user_2, remote_work: true, remote_working_hours: "月79h以下")
      insert(:user_job_profile, user: user_3, remote_work: true, remote_working_hours: nil)

      query =
        {[{:job_searching, true}, {:remote_work, true}, {:remote_working_hours, "月160h以上"}], %{},
         []}

      assert %{entries: [%{id: ^id_1}, %{id: ^id_3}]} =
               UserSearches.search_users_by_job_profile_and_skill_score(query)
    end

    test "only remote work and work holiday", %{user_1: %{id: id} = user_1, user_2: user_2} do
      insert(:user_job_profile, user: user_1, remote_work: true, remote_work_holidays: true)
      insert(:user_job_profile, user: user_2, remote_work: true, remote_work_holidays: false)

      query =
        {[
           {:job_searching, true},
           {:remote_work, true},
           {:remote_work_holidays, true}
         ], %{}, []}

      assert %{entries: [%{id: ^id}]} =
               UserSearches.search_users_by_job_profile_and_skill_score(query)
    end

    test "having skill_panel_2", %{
      user_1: user_1,
      user_2: %{id: id} = user_2,
      skill_panel_2: panel
    } do
      insert(:user_job_profile, user: user_1)
      insert(:user_job_profile, user: user_2)

      query = {[{:job_searching, true}], %{}, [%{skill_panel: panel.id}]}

      assert %{entries: [%{id: ^id}]} =
               UserSearches.search_users_by_job_profile_and_skill_score(query)
    end

    test "having skill_panel 1 & 2", %{
      user_1: user_1,
      user_2: %{id: id} = user_2,
      skill_panel_1: panel_1,
      skill_panel_2: panel_2
    } do
      insert(:user_job_profile, user: user_1)
      insert(:user_job_profile, user: user_2)

      query =
        {[{:job_searching, true}], %{}, [%{skill_panel: panel_1.id}, %{skill_panel: panel_2.id}]}

      assert %{entries: [%{id: ^id}]} =
               UserSearches.search_users_by_job_profile_and_skill_score(query)
    end

    test "having skill_panel 1 and open class 2", %{
      user_1: user_1,
      user_2: %{id: id} = user_2,
      skill_panel_1: panel_1
    } do
      insert(:user_job_profile, user: user_1)
      insert(:user_job_profile, user: user_2)

      query = {[{:job_searching, true}], %{}, [%{skill_panel: panel_1.id, class: 2}]}

      assert %{entries: [%{id: ^id}]} =
               UserSearches.search_users_by_job_profile_and_skill_score(query)
    end

    test "having skill_panel 1 and open class 1 and skilled", %{
      user_1: user_1,
      user_2: %{id: id} = user_2,
      skill_panel_1: panel_1
    } do
      insert(:user_job_profile, user: user_1)
      insert(:user_job_profile, user: user_2)

      query =
        {[{:job_searching, true}], %{}, [%{skill_panel: panel_1.id, class: 1, level: "skilled"}]}

      assert %{entries: [%{id: ^id}]} =
               UserSearches.search_users_by_job_profile_and_skill_score(query)
    end
  end
end

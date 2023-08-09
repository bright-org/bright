defmodule BrightWeb.SkillPanelLive.SkillPanel do
  @moduledoc """
  成長パネルとスキルパネル 両画面の共通実装用モジュール
  """

  def commons do
    quote do
      alias Bright.SkillPanels

      import BrightWeb.SkillPanelLive.SkillPanelComponents

      @queries ~w(class)

      defp assign_skill_panel(socket, "dummy_id") do
        # TODO: dummy_idはダミー用で実装完了後に消すこと
        # リンクを出すための実装
        skill_panel =
          SkillPanels.list_skill_panels()
          |> Enum.sort_by(& &1.inserted_at, {:desc, NaiveDateTime})
          |> List.first()

        assign_skill_panel(socket, skill_panel.id)
      end

      defp assign_skill_panel(socket, skill_panel_id) do
        current_user = socket.assigns.current_user

        skill_panel =
          SkillPanels.get_skill_panel!(skill_panel_id)
          |> Bright.Repo.preload(
            skill_classes: [skill_class_scores: Ecto.assoc(current_user, :skill_class_scores)]
          )

        socket
        |> assign(:skill_panel, skill_panel)
      end

      defp assign_skill_class_and_score(socket, nil),
        do: assign_skill_class_and_score(socket, "1")

      defp assign_skill_class_and_score(socket, class) do
        class = String.to_integer(class)
        skill_class = socket.assigns.skill_panel.skill_classes |> Enum.find(&(&1.class == class))
        # List.first(): preload時に絞り込んでいるためfirstで取得可能
        skill_class_score = skill_class.skill_class_scores |> List.first()

        socket
        |> assign(:skill_class, skill_class)
        |> assign(:skill_class_score, skill_class_score)
      end

      defp assign_page_sub_title(socket) do
        socket
        |> assign(:page_sub_title, socket.assigns.skill_panel.name)
      end

      defp assign_path(socket, url) do
        %{path: path, query: query} = URI.parse(url)

        query =
          URI.decode_query(query || "")
          |> Map.take(@queries)

        socket
        |> assign(path: path)
        |> assign(query: query)
      end
    end
  end

  defmacro __using__(_opts) do
    apply(__MODULE__, :commons, [])
  end
end

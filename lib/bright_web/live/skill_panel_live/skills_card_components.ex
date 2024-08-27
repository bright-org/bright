defmodule BrightWeb.SkillPanelLive.SkillCardComponents do
  use BrightWeb, :component

  import BrightWeb.MegaMenuComponents, only: [mega_menu_button: 1]

  def switch_user(assigns) do
    ~H"""
    <.mega_menu_button
      id="related_user_card_menu"
      dropdown_offset_skidding="307"
      color="bg-white"
      divide={false}
    >
      <:button_content>
        <div class="flex">
          <img
            class="object-cover inline-block h-[28px] w-[28px] rounded-full mr-2"
            src={Bright.UserProfiles.icon_url(@display_user.user_profile.icon_file_path)}
          />
          <span class="mt-1"><%= @display_user.name%></span>
        </div>
        <div class="mt-1 mr-2"><.icon name="hero-chevron-down" /> </div>
      </:button_content>
      <.live_component
        id="related_user"
        module={BrightWeb.CardLive.RelatedUserCardComponent}
        current_user={@current_user}
        purpose="menu"
        without_me={false}
      />
    </.mega_menu_button>
    """
  end

  def switch_skill(assigns) do
    ~H"""
    <.mega_menu_button
      id="skill_card_menu"
      dropdown_offset_skidding="100"
      menu_width={"lg:w-[340px]"}
      color="bg-white"
      divide={false}
    >
      <:button_content>
        <div class="flex mr-4 my-1">
        <.icon name="hero-arrow-path" />
          スキル切替
        </div>
      </:button_content>
      <div class="mt-2">
      <.live_component
        id="skill_list"
        module={BrightWeb.SkillListComponent}
        display_user={@display_user}
        me={@me}
        root="panels"
        anonymous={@anonymous}
        career_field={nil}
        current_skill_class={@skill_class}
        per_page={10}
      />
      </div>
    </.mega_menu_button>

    """
  end
end

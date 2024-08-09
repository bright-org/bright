defmodule BrightWeb.UserAuthComponents do
  @moduledoc """
  Components for user auth.
  """
  alias Bright.Accounts.UserSocialAuth
  use Phoenix.Component
  import BrightWeb.CoreComponents, only: [error: 1, translate_error: 1]

  @doc """
  Auth form.
  """
  attr :for, :any, required: true, doc: "the datastructure for the form"
  attr :as, :any, default: nil, doc: "the server side parameter to collect all input under"

  attr :rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target multipart),
    doc: "the arbitrary HTML attributes to apply to the form tag"

  slot :inner_block, required: true

  def auth_form(assigns) do
    ~H"""
    <.form
      :let={f}
      for={@for}
      as={@as}
      class="flex mt-8 mx-auto relative flex-col-reverse lg:flex-row"
      {@rest}
    >
      <%= render_slot(@inner_block, f) %>
    </.form>
    """
  end

  @doc """
  Section for form
  """
  attr :variant, :string, default: "center", values: ~w(center center-w-full left right)

  slot :inner_block

  def form_section(assigns) do
    ~H"""
    <section
      class={[
        @variant == "center" && "flex flex-col mx-auto",
        @variant == "center-w-full" && "flex flex-col w-full",
        @variant == "left" && "flex flex-col border-0 mt-0 pr-0 w-full lg:border-r lg:border-solidlg: border-brightGray-300 lg:mt-4 lg:pr-16 lg:w-2/4",
        @variant == "right" && "flex flex-col pt-0 pr-0 pl-0 w-full lg:pl-16 lg:w-2/4",
      ]}
    >
      <%= render_slot(@inner_block) %>
    </section>
    """
  end

  @doc """
  Input with label
  """
  attr :id, :any, default: nil
  attr :label_text, :string, required: true

  attr :type, :string,
    default: "text",
    values: ~w(email password text number)

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list, default: []

  attr :variant, :string, default: "normal", values: ~w(normal w-full)

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)

  slot :under_block, doc: "html under input"

  def input_with_label(assigns) do
    ~H"""
    <label for={@id} class={["mt-4", @variant == "w-full" && "block mx-auto max-w-xs w-full"]}>
      <span class="block font-bold mb-2 text-xs"><%= @label_text %></span>
      <.input field={@field} id={@id} type={@type} {@rest} />
      <%= render_slot(@under_block) %>
    </label>
    """
  end

  @doc """
  Renders an input and error messages.
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :value, :any

  attr :type, :string,
    default: "text",
    values: ~w(email password text)

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list, default: []

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(field.errors, &translate_error(&1)))
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <input
        type={@type}
        name={@name}
        id={@id}
        value={Phoenix.HTML.Form.normalize_value(@type, @value)}
        class={[
          "border border-solid border-black max-w-xs px-4 py-2 rounded w-full"
        ]}
        {@rest}
      />
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  @doc """
  Header for auth form.
  """
  slot :inner_block

  def header(assigns) do
    ~H"""
    <h1 class="font-bold text-center text-3xl">
      <span class="before:bg-bgGem before:bg-9 before:bg-left before:bg-no-repeat before:content-[''] before:h-9 before:inline-block before:relative before:top-[5px] before:w-9"><%= render_slot(@inner_block) %></span>
    </h1>
    """
  end

  @doc """
  Description for auth form.
  """
  attr :text_size, :string, default: "text-sm", values: ~w(text-sm text-xs)
  slot :inner_block

  def description(assigns) do
    ~H"""
    <p class={["mt-8 mx-auto w-fit", @text_size]}><%= render_slot(@inner_block) %></p>
    """
  end

  @doc """
  Link with text
  """
  attr :href, :string

  slot :inner_block

  def link_text(assigns) do
    ~H"""
    <p class="mt-8 text-link text-center text-xs"><.link navigate={@href} class="underline"><%= render_slot(@inner_block) %></.link></p>
    """
  end

  @doc """
  Input under link
  """
  attr :href, :string

  slot :inner_block

  def link_text_under_input(assigns) do
    ~H"""
    <.link href={@href} class="block mr-2 mt-1 text-link text-right text-xs underline"><%= render_slot(@inner_block) %></.link>
    """
  end

  @doc """
  Inline link text
  """
  attr :href, :string
  attr :rest, :global

  slot :inner_block

  def link_inline_text(assigns) do
    ~H"""
    <.link href={@href} class="text-link text-xs underline" {@rest}><%= render_slot(@inner_block) %></.link>
    """
  end

  @doc """
  Button-style link
  """
  attr :href, :string

  slot :inner_block

  def link_button(assigns) do
    ~H"""
    <.link href={@href} class="text-center bg-white border border-solid border-black font-bold mt-16 mx-auto px-4 py-2 rounded select-none text-black w-40">
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end

  @doc """
  Button for auth form.
  """
  attr :variant, :string, default: "normal", values: ~w(normal mt-sm mt-xs mx-auto)
  attr :disabled, :boolean, default: false

  slot :inner_block

  def button(assigns) do
    ~H"""
    <button
      class={[
        "bg-brightGray-900 border border-solid border-brightGray-900 font-bold max-w-xs px-4 py-2 rounded select-none text-white w-full hover:filter hover:brightness-[80%] disabled:bg-gray-400 disabled:border-gray-400",
        @variant == "normal" && "mt-12",
        @variant == "mx-auto" && "mt-12 mx-auto",
        @variant == "mt-sm" && "mt-8",
        @variant == "mt-xs" && "mt-7"
      ]}
      disabled={@disabled}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  @doc """
  Social auth button for auth form.
  """
  attr :variant, :string, values: ~w(google github facebook twitter)
  attr :href, :string
  attr :method, :string, default: "get"

  slot :inner_block

  def social_auth_button(assigns) do
    # NOTE: Facebook, Twitter は実装できるまで bg-gray-400 にする。完了したら以下のスタイルに差し替える
    # bg-sns-facebook
    # bg-sns-twitter
    ~H"""
    <.link href={@href} method={@method}>
      <button
        type="button"
        class={[
          "bg-no-repeat border-solid bg-5 bg-left-2.5 border font-bold max-w-xs px-4 py-2 rounded select-none w-full hover:filter hover:brightness-[80%]",
          @variant == "google" && "bg-bgGoogle border-black mt-4 text-black",
          @variant == "github" && "bg-bgGithub bg-sns-github border-github mt-6 text-white",
          @variant == "facebook" && "bg-bgFacebook bg-gray-400 border-facebook mt-6 text-white",
          @variant == "twitter" && "bg-bgNewTwitter bg-gray-400 border-twitter mt-6 text-white"
        ]}
      >
        <%= render_slot(@inner_block) %>
      </button>
    </.link>
    """
  end

  @doc """
  Social auth banner
  """

  attr :variant, :string, values: ~w(google github facebook twitter)

  def social_auth_banner(assigns) do
    ~H"""
    <section class="flex flex-col mt-8">
      <span class="block font-bold mb-2 text-xs max-w-xs mx-auto w-full">認証</span>
      <span
        class={[
          "block bg-no-repeat border-solid bg-5 bg-left-2.5 border-b font-bold max-w-xs mx-auto px-4 py-2 select-none text-center w-full",
          @variant == "google" && "bg-bgGoogle border-black text-black",
          @variant == "github" && "bg-bgGithub bg-sns-github border-github text-white",
          @variant == "facebook" && "bg-bgFacebook bg-sns-facebook border-facebook text-white",
          @variant == "twitter" && "bg-bgTwitter bg-sns-twitter border-twitter text-white",
        ]}
      >
        <%= UserSocialAuth.provider_name(String.to_atom(@variant)) %>
      </span>
    </section>
    """
  end

  @doc """
  Or text.
  """
  slot :inner_block

  def or_text(assigns) do
    ~H"""
    <p class="bg-white border border-solid border-brightGray-300 flex h-20 items-center justify-center ml-auto mr-auto mt-4 rounded-full static text-brightGray-500 text-xs w-20 z-20 lg:absolute lg:left-2/4 lg:-ml-10 lg:mr-0 lg:-mt-10 lg:top-2/4"><%= render_slot(@inner_block) %></p>
    """
  end
end

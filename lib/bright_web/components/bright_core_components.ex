defmodule BrightWeb.BrightCoreComponents do
  @moduledoc """
  Bright Core Components
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  import BrightWeb.Gettext

  import BrightWeb.CoreComponents,
    only: [
      icon: 1,
      hide: 2,
      translate_error: 1,
      error: 1
    ]

  @doc """
  Renders flash notices without put_flash

  ## Examples

      <.flash kind={:info} flash={@other_flash} />
      <.flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.flash>
  """
  attr :id, :string, default: "modal_flash", doc: "the optional id of flash container"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup"
  attr :hide_timeout, :boolean, default: true
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"

  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def flash(assigns) do
    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Map.get(@flash, @kind)}
      id={@id}
      phx-hook={@hide_timeout && "HideFlashTimeout"}
      data-kind={Atom.to_string(@kind)}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      role="alert"
      class={[
        "animate-fade-in-bottom fixed inset-x-0 bottom-2 m-auto w-80 sm:w-96 z-[65] rounded-lg p-3 ring-1",
        @kind == :info && "bg-brightGreen-50 text-brightGreen-900 ring-brightGreen-600 fill-brightGreen-900",
        @kind == :error && "bg-attention-50 text-attention-900 shadow-md ring-attention-600 fill-attention-900"
      ]}
      {@rest}
    >
      <div class="flex">
        <p class="flex items-center gap-1.5 text-sm leading-6 px-2">
          <.icon :if={@kind == :info} name="hero-information-circle-mini" class="h-4 w-4" />
          <.icon :if={@kind == :error} name="hero-exclamation-circle-mini" class="h-4 w-4" />
        </p>
        <span class="flex-1 break-words mr-5"><%= msg %></span>
        <button type="button" class="group absolute top-1 right-1 p-2" aria-label={gettext("close")}>
          <.icon name="hero-x-mark-solid" class="h-5 w-5 opacity-40 group-hover:opacity-70" />
        </button>
      </div>
    </div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  def flash_group(assigns) do
    ~H"""
    <.flash kind={:info} flash={@flash} />
    <.flash kind={:error} flash={@flash} />
    """
  end

  @doc """
  Renders a button.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" class="ml-2">Send!</.button>
  """
  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value)

  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      class={[
        "bg-brightGray-900 border border-solid border-brightGray-900 cursor-pointer font-bold px-4 py-2 rounded select-none text-center text-white w-80 hover:opacity-50",
        "phx-submit-loading:opacity-75",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  @doc """
  Renders a action button
  """
  attr :type, :string, default: "button"
  attr :icon, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled)

  slot :inner_block, required: true

  def action_button(%{icon: nil} = assigns) do
    ~H"""
    <button type={@type} class={["text-sm font-bold px-5 py-2 rounded border border-base", @class]} {@rest}>
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  def action_button(assigns) do
    ~H"""
    <button
      type={@type}
      class={["text-sm font-bold border border-base rounded py-1.5 pl-3 flex items-center", @class]}
      @rest
    >
      <%= render_slot(@inner_block) %>
      <span
        class="material-icons relative ml-2 px-1 before:content[''] before:absolute before:left-0 before:top-[-7px] before:bg-brightGray-200 before:w-[1px] before:h-[38px]"
        ><%= @icon %></span>
    </button>
    """
  end

  @doc """
  Renders an input with label and error messages.

  A `Phoenix.HTML.FormField` may be passed as argument,
  which is used to retrieve the input name, id, and values.
  Otherwise all attributes may be passed explicitly.

  ## Types

  This function accepts all HTML input types, considering that:

    * You may also set `type="select"` to render a `<select>` tag

    * `type="checkbox"` is used exclusively to render boolean values

    * For live file uploads, see `Phoenix.Component.live_file_input/1`

  See https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input
  for more information.

  ## Examples

      <.input field={@form[:email]} type="email" />
      <.input name="my-input" errors={["oh no!"]} />
  """
  attr :id, :any, default: nil
  attr :container_class, :string, default: ""
  attr :div_class, :string, default: ""
  attr :input_class, :string, default: ""
  attr :label_class, :string, default: ""
  attr :after_label_class, :string, default: ""
  attr :error_class, :string, default: ""
  attr :name, :any
  attr :label, :string, default: nil
  attr :after_label, :string, default: nil
  attr :value, :any

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file hidden month number password
               range radio search select tel text textarea time url week)

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list, default: []
  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)

  slot :inner_block

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(field.errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "checkbox", value: value} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn -> Phoenix.HTML.Form.normalize_value("checkbox", value) end)

    ~H"""
    <div phx-feedback-for={@name}>
      <label class={["flex items-center", @container_class]}>
        <input type="hidden" name={@name} value="false" />
        <input
          type="checkbox"
          id={@id}
          name={@name}
          value="true"
          checked={@checked}
          class={@input_class}
          {@rest}
        />
        <span class={["ml-1", @label_class]}><%= @label %></span>
      </label>
      <div class={@error_class}>
        <.error :for={msg <- @errors}><%= msg %></.error>
      </div>
    </div>
    """
  end

  def input(%{type: "radio", value: value} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn -> Phoenix.HTML.Form.normalize_value("radio", value) end)

    ~H"""
    <div phx-feedback-for={@name}>
      <label class={["flex items-center", @container_class]}>
        <input
          type="radio"
          id={@id}
          name={@name}
          checked={@checked}
          value={@value}
          class={["border border-brightGray-200", @input_class]}
          {@rest}
        />
        <span class={["ml-1", @label_class]}><%= @label %></span>
      </label>
      <div class={@error_class}>
        <.error :for={msg <- @errors}><%= msg %></.error>
      </div>

    </div>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <label for={@id} class={@label_class}><%= @label %></label>
      <select
        id={@id}
        name={@name}
        class={[
          "border border-brightGray-200 ml-4 px-2 py-1 rounded",
          @input_class
        ]}
        multiple={@multiple}
        {@rest}
      >
        <option :if={@prompt} value=""><%= @prompt %></option>
        <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
      </select>
      <div class={@error_class}>
        <.error :for={msg <- @errors}><%= msg %></.error>
      </div>
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name} class={@div_class}>
      <textarea
        id={@id}
        name={@name}
        class={[
          "border border-brightGray-200 px-2 py-1 rounded",
          @input_class,
        ]}
        {@rest}
      ><%= Phoenix.HTML.Form.normalize_value("textarea", @value) %></textarea>
      <div class={@error_class}>
        <.error :for={msg <- @errors}><%= msg %></.error>
      </div>
    </div>
    """
  end

  # All other inputs text, datetime-local, url, password, etc. are handled here...
  def input(assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <label for={@id} class={["flex items-center", @container_class]}>
        <span class={@label_class}><%= @label %></span>
        <input
          type={@type}
          name={@name}
          id={@id}
          value={Phoenix.HTML.Form.normalize_value(@type, @value)}
          class={[
            "border border-brightGray-200 px-2 py-1 rounded w-40",
            @input_class,
          ]}
          {@rest}
        />
        <span class={@after_label_class}><%= @after_label %></span>
      </label>
      <div class={@error_class}>
        <.error :for={msg <- @errors}><%= Phoenix.HTML.raw(msg) %></.error>
      </div>
    </div>
    """
  end

  @doc """
  Renders a label.
  """
  attr :for, :string, default: nil
  slot :inner_block, required: true

  def label(assigns) do
    ~H"""
    <label for={@for} class="block text-sm font-semibold leading-6 text-zinc-800">
      <%= render_slot(@inner_block) %>
    </label>
    """
  end

  @doc """
  Render a content with anchor link.
  """
  @regex_link ~r{https?://[a-zA-Z0-9.\-_@:/~?%&;=+#',()*!]+}

  attr :text, :string, required: true
  attr :attributes, :list, default: []

  def text_to_html_with_link(assigns) do
    ~H"<%= Phoenix.HTML.raw _text_to_html_with_link(@text, @attributes) %>"
  end

  defp _text_to_html_with_link(text, attributes) do
    Regex.split(@regex_link, text, include_captures: true)
    |> Enum.map_join(fn part ->
      URI.new(part)
      |> case do
        {:ok, %{scheme: scheme}} when scheme in ["http", "https"] ->
          # 完全な形のURIのみリンクに変換
          link_tag(part)

        {:ok, %{scheme: nil}} ->
          safe_to_string(part)

        {:error, _} ->
          safe_to_string(part)
      end
    end)
    # 全体をhtmlにする際は個別にエスケープしているのでエスケープしない
    |> Phoenix.HTML.Format.text_to_html(attributes: attributes, escape: false)
    |> Phoenix.HTML.safe_to_string()
  end

  defp link_tag(url) do
    ~s(<a class="text-blue-600 hover:underline" target="_blank" href="#{url}">#{safe_to_string(url)}</a>)
  end

  defp safe_to_string(text) do
    text |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string()
  end
end

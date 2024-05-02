defmodule PoloWeb.ClientLive.Components do
  use Phoenix.Component
  import PoloWeb.CoreComponents

  attr :actions, :list, required: true
  attr :custom_class, :string
  attr :selected, :string, default: ""

  def menu(assigns) do
    ~H"""
    <menu class={["c-menu", @custom_class]}>
      <%= for action <- @actions do %>
        <li class={[
          @selected == action.value && "is-selected"
        ]}>
          <label>
            <input
              type="radio"
              name={action.name}
              value={action.value}
              checked={@selected == action.value}
              class="hidden"
              phx-click={Map.get(action, :click_event, nil) && action.click_event}
            />
            <span><%= action.label %></span>
          </label>
        </li>
      <% end %>
    </menu>
    """
  end

  attr :field, :map, required: true
  attr :sort_param, :string, required: true
  attr :drop_param, :string, required: true
  attr :rest, :global, default: %{class: "c-embedded-inputs"}
  slot :inputs, required: true

  def embedded_inputs(assigns) do
    ~H"""
    <.inputs_for :let={nested} field={@field}>
      <div {@rest}>
        <input type="hidden" name={@sort_param} value={nested.index} />

        <%= render_slot(@inputs, nested) %>

        <label class="c-embedded-inputs__remove">
          <.icon name="hero-trash" />
          <input
            disabled={nested.index === 0}
            type="checkbox"
            name={@drop_param}
            value={nested.index}
            aria-label="Remove"
          />
        </label>
      </div>

      <input type="hidden" name={@drop_param} />
    </.inputs_for>

    <label class="c-embedded-inputs__add">
      <input type="checkbox" name={@sort_param} />
      <.icon name="hero-plus-circle" />
      <span>Add new value</span>
    </label>
    """
  end
end

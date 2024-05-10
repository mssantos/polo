defmodule PoloWeb.ClientLive.Components do
  use Phoenix.Component

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
end

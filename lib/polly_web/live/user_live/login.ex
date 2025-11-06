defmodule PollyWeb.UserLive.Login do
  use PollyWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-sm space-y-4">
        <div class="text-center">
          <.header>
            <p class="text-3xl font-bold">Hackathon Voting Login</p>
            <:subtitle>
              <div class="mt-4 p-4 bg-blue-50 rounded-lg">
                <p class="font-semibold text-blue-900">Test Credentials:</p>
                <p class="text-sm text-blue-800 mt-2">team1@test.com / pass1</p>
                <p class="text-sm text-blue-800">team2@test.com / pass2</p>
                <p class="text-sm text-blue-800">... (team3-8 follow same pattern)</p>
              </div>
            </:subtitle>
          </.header>
        </div>

        <.form
          :let={f}
          for={@form}
          id="login_form_password"
          action={~p"/users/log-in"}
          phx-submit="submit_password"
          phx-trigger-action={@trigger_submit}
        >
          <.input
            readonly={!!@current_scope}
            field={f[:email]}
            type="email"
            label="Email"
            autocomplete="username"
            required
            phx-mounted={JS.focus()}
          />
          <.input
            field={@form[:password]}
            type="password"
            label="Password"
            autocomplete="current-password"
            required
          />
          <.button class="btn btn-primary w-full" name={@form[:remember_me].name} value="true">
            Log in <span aria-hidden="true">→</span>
          </.button>
        </.form>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    email =
      Phoenix.Flash.get(socket.assigns.flash, :email) ||
        get_in(socket.assigns, [:current_scope, Access.key(:user), Access.key(:email)])

    form = to_form(%{"email" => email}, as: "user")

    {:ok, assign(socket, form: form, trigger_submit: false)}
  end

  @impl true
  def handle_event("submit_password", _params, socket) do
    {:noreply, assign(socket, :trigger_submit, true)}
  end
end

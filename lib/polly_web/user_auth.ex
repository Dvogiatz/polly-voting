defmodule PollyWeb.UserAuth do
  use PollyWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  alias Polly.Accounts.{Scope, User}

  # Remember me cookie settings (not used in in-memory mode)
  # @max_cookie_age_in_days 14
  # @remember_me_cookie "_polly_web_user_remember_me"
  # @remember_me_options [
  #   sign: true,
  #   max_age: @max_cookie_age_in_days * 24 * 60 * 60,
  #   same_site: "Lax"
  # ]

  # How old the session token should be before a new one is issued. When a request is made
  # with a session token older than this value, then a new session token will be created
  # and the session and remember-me cookies (if set) will be updated with the new token.
  # Lowering this value will result in more tokens being created by active users. Increasing
  # it will result in less time before a session token expires for a user to get issued a new
  # token. This can be set to a value greater than `@max_cookie_age_in_days` to disable
  # the reissuing of tokens completely.
  # Note: Not used in in-memory mode
  # @session_reissue_age_in_days 7

  @doc """
  Logs the user in.

  Redirects to the session's `:user_return_to` path
  or falls back to the `signed_in_path/1`.
  """
  def log_in_user(conn, user, _params \\ %{}) do
    user_return_to = get_session(conn, :user_return_to)

    conn
    |> renew_session()
    |> put_session(:user_id, user.id)
    |> put_session(:user_email, user.email)
    |> redirect(to: user_return_to || signed_in_path(conn))
  end

  @doc """
  Logs the user out.

  It clears all session data for safety. See renew_session.
  """
  def log_out_user(conn) do
    conn
    |> renew_session()
    |> redirect(to: ~p"/")
  end

  @doc """
  Authenticates the user by looking into the session and remember me token.
  """
  def fetch_current_scope_for_user(conn, _opts) do
    user_id = get_session(conn, :user_id) || get_remember_me_user_id(conn)

    if user_id do
      case Polly.Storage.get_user(user_id) do
        nil ->
          assign(conn, :current_scope, Scope.for_user(nil))

        user_data ->
          user =
            struct(
              User,
              Map.put(user_data, :project, Polly.Storage.get_project(user_data.project_id))
            )

          conn
          |> put_session(:user_id, user.id)
          |> assign(:current_scope, Scope.for_user(user))
      end
    else
      assign(conn, :current_scope, Scope.for_user(nil))
    end
  end

  defp get_remember_me_user_id(_conn) do
    # Remember me not supported in in-memory mode
    nil
  end

  defp renew_session(conn) do
    delete_csrf_token()

    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

  @doc """
  Handles mounting and authenticating the current_scope in LiveViews.

  ## `on_mount` arguments

    * `:mount_current_scope` - Assigns current_scope
      to socket assigns based on user_token, or nil if
      there's no user_token or no matching user.

    * `:require_authenticated` - Authenticates the user from the session,
      and assigns the current_scope to socket assigns based
      on user_token.
      Redirects to login page if there's no logged user.

  ## Examples

  Use the `on_mount` lifecycle macro in LiveViews to mount or authenticate
  the `current_scope`:

      defmodule PollyWeb.PageLive do
        use PollyWeb, :live_view

        on_mount {PollyWeb.UserAuth, :mount_current_scope}
        ...
      end

  Or use the `live_session` of your router to invoke the on_mount callback:

      live_session :authenticated, on_mount: [{PollyWeb.UserAuth, :require_authenticated}] do
        live "/profile", ProfileLive, :index
      end
  """
  def on_mount(:mount_current_scope, _params, session, socket) do
    {:cont, mount_current_scope(socket, session)}
  end

  def on_mount(:require_authenticated, _params, session, socket) do
    socket = mount_current_scope(socket, session)

    if socket.assigns.current_scope && socket.assigns.current_scope.user do
      {:cont, socket}
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(:error, "You must log in to access this page.")
        |> Phoenix.LiveView.redirect(to: ~p"/users/log-in")

      {:halt, socket}
    end
  end

  def on_mount(:require_sudo_mode, _params, session, socket) do
    socket = mount_current_scope(socket, session)

    # Sudo mode not supported in in-memory mode - always allow
    {:cont, socket}
  end

  defp mount_current_scope(socket, session) do
    Phoenix.Component.assign_new(socket, :current_scope, fn ->
      user_id = session["user_id"]

      user =
        if user_id do
          case Polly.Storage.get_user(user_id) do
            nil ->
              nil

            user_data ->
              struct(
                User,
                Map.put(user_data, :project, Polly.Storage.get_project(user_data.project_id))
              )
          end
        end

      Scope.for_user(user)
    end)
  end

  @doc "Returns the path to redirect to after log in."
  # Redirect to home (voting page)
  def signed_in_path(_), do: ~p"/"

  @doc """
  Plug for routes that require the user to be authenticated.
  """
  def require_authenticated_user(conn, _opts) do
    if conn.assigns.current_scope && conn.assigns.current_scope.user do
      conn
    else
      conn
      |> put_flash(:error, "You must log in to access this page.")
      |> maybe_store_return_to()
      |> redirect(to: ~p"/users/log-in")
      |> halt()
    end
  end

  @doc """
  Plug to redirect already authenticated users away from login/register pages.
  """
  def redirect_if_user_is_authenticated(conn, _opts) do
    if conn.assigns.current_scope && conn.assigns.current_scope.user do
      conn
      |> redirect(to: signed_in_path(conn))
      |> halt()
    else
      conn
    end
  end

  defp maybe_store_return_to(%{method: "GET"} = conn) do
    put_session(conn, :user_return_to, current_path(conn))
  end

  defp maybe_store_return_to(conn), do: conn
end

defmodule MayIsBikeMonthWeb.ParticipantAuth do
  use MayIsBikeMonthWeb, :verified_routes
  import Plug.Conn
  import Phoenix.Controller

  alias Phoenix.LiveView
  alias MayIsBikeMonth.Participants

  def on_mount(:current_participant, _params, session, socket) do
    case session do
      %{"participant_id" => participant_id} ->
        {:cont,
         Phoenix.Component.assign_new(socket, :current_participant, fn ->
           Participants.get_participant(participant_id)
         end)}

      %{} ->
        {:cont, Phoenix.Component.assign(socket, :current_participant, nil)}
    end
  end

  def on_mount(:ensure_authenticated, _params, session, socket) do
    case session do
      %{"participant_id" => participant_id} ->
        new_socket =
          Phoenix.Component.assign_new(socket, :current_participant, fn ->
            Participants.get_participant!(participant_id)
          end)

        %Participants.Participant{} = new_socket.assigns.current_participant
        {:cont, new_socket}

      %{} ->
        {:halt, redirect_require_login(socket)}
    end
  rescue
    Ecto.NoResultsError -> {:halt, redirect_require_login(socket)}
  end

  defp redirect_require_login(socket) do
    socket
    |> LiveView.put_flash(:error, "Please sign in")
    |> LiveView.redirect(to: ~p"/")
  end

  @doc """
  Logs the participant in.

  It renews the session ID and clears the whole session
  to avoid fixation attacks. See the renew_session
  function to customize this behaviour.

  It also sets a `:live_socket_id` key in the session,
  so LiveView sessions are identified and automatically
  disconnected on log out. The line can be safely removed
  if you are not using LiveView.
  """
  def log_in_participant(conn, participant) do
    participant_return_to = get_session(conn, :participant_return_to)
    conn = assign(conn, :current_participant, participant)

    conn
    |> renew_session()
    |> put_session(:participant_id, participant.id)
    |> put_session(:live_socket_id, "participants_sessions:#{participant.id}")
    |> redirect(to: participant_return_to || ~p"/")
  end

  defp renew_session(conn) do
    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

  @doc """
  Logs the participant out.

  It clears all session data for safety. See renew_session.
  """
  def log_out_participant(conn) do
    if live_socket_id = get_session(conn, :live_socket_id) do
      MayIsBikeMonthWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
    end

    conn
    |> renew_session()
    |> redirect(to: ~p"/")
  end

  @doc """
  Authenticates the participant by looking into the session.
  """
  def fetch_current_participant(conn, _opts) do
    participant_id = get_session(conn, :participant_id)
    Honeybadger.context(participant_id: participant_id)
    participant = participant_id && Participants.get_participant(participant_id)
    assign(conn, :current_participant, participant)
  end

  @doc """
  Used for routes that require the participant to not be authenticated.
  """
  def redirect_if_participant_is_authenticated(conn, _opts) do
    if conn.assigns[:current_participant] do
      conn
      |> redirect(to: ~p"/")
      |> halt()
    else
      conn
    end
  end

  @doc """
  Used for routes that require the participant to be authenticated.
  """
  def require_authenticated_participant(conn, _opts) do
    if conn.assigns[:current_participant] do
      conn
    else
      conn
      |> put_flash(:error, "You must log in to access this page.")
      |> maybe_store_return_to()
      |> redirect(to: ~p"/")
      |> halt()
    end
  end

  def require_authenticated_admin(conn, _opts) do
    participant = conn.assigns[:current_participant]

    if participant && MayIsBikeMonth.Participants.admin?(participant) do
      assign(conn, :current_admin, participant)
    else
      conn
      |> put_flash(:error, "You must be an admin to access that page")
      |> maybe_store_return_to()
      |> redirect(to: "/")
      |> halt()
    end
  end

  defp maybe_store_return_to(%{method: "GET"} = conn) do
    %{request_path: request_path, query_string: query_string} = conn
    return_to = if query_string == "", do: request_path, else: request_path <> "?" <> query_string
    put_session(conn, :participant_return_to, return_to)
  end

  defp maybe_store_return_to(conn), do: conn
end

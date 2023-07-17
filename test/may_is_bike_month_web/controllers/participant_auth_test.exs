defmodule MayIsBikeMonthWeb.ParticipantAuthTest do
  use MayIsBikeMonthWeb.ConnCase, async: true

  alias MayIsBikeMonth.Participants
  alias MayIsBikeMonthWeb.ParticipantAuth
  import MayIsBikeMonth.ParticipantsFixtures

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, MayIsBikeMonthWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{participant: participant_fixture(), conn: conn}
  end

  describe "log_in_participant/3" do
    test "stores the participant id in the session", %{conn: conn, participant: participant} do
      conn = ParticipantAuth.log_in_participant(conn, participant)
      assert id = get_session(conn, :participant_id)
      assert get_session(conn, :live_socket_id) == "participants_sessions:#{id}"
      assert redirected_to(conn) == "/"
      assert Participants.get_participant!(id)
    end

    test "clears everything previously stored in the session", %{
      conn: conn,
      participant: participant
    } do
      conn =
        conn
        |> put_session(:to_be_removed, "value")
        |> ParticipantAuth.log_in_participant(participant)

      refute get_session(conn, :to_be_removed)
    end

    test "redirects to the configured path", %{conn: conn, participant: participant} do
      conn =
        conn
        |> put_session(:participant_return_to, "/hello")
        |> ParticipantAuth.log_in_participant(participant)

      assert redirected_to(conn) == "/hello"
    end
  end

  describe "logout_participant/1" do
    test "erases session and cookies", %{conn: conn} do
      conn =
        conn
        |> put_session(:participant_id, "123")
        |> fetch_cookies()
        |> ParticipantAuth.log_out_participant()

      refute get_session(conn, :participant_id)
      assert redirected_to(conn) == "/"
    end

    test "broadcasts to the given live_socket_id", %{conn: conn} do
      live_socket_id = "participants_sessions:abcdef-token"
      MayIsBikeMonthWeb.Endpoint.subscribe(live_socket_id)

      conn
      |> put_session(:live_socket_id, live_socket_id)
      |> ParticipantAuth.log_out_participant()

      assert_receive %Phoenix.Socket.Broadcast{
        event: "disconnect",
        topic: "participants_sessions:abcdef-token"
      }
    end
  end

  describe "fetch_current_participant/2" do
    test "authenticates participant from session", %{conn: conn, participant: participant} do
      conn =
        conn
        |> put_session(:participant_id, participant.id)
        |> ParticipantAuth.fetch_current_participant([])

      assert conn.assigns.current_participant.id == participant.id
    end
  end

  describe "redirect_if_participant_is_authenticated/2" do
    test "redirects if participant is authenticated", %{conn: conn, participant: participant} do
      conn =
        conn
        |> assign(:current_participant, participant)
        |> ParticipantAuth.redirect_if_participant_is_authenticated([])

      assert conn.halted
      assert redirected_to(conn) == "/"
    end

    test "does not redirect if participant is not authenticated", %{conn: conn} do
      conn = ParticipantAuth.redirect_if_participant_is_authenticated(conn, [])
      refute conn.halted
      refute conn.status
    end
  end

  describe "require_authenticated_participant/2" do
    test "redirects if participant is not authenticated", %{conn: conn} do
      conn = conn |> fetch_flash() |> ParticipantAuth.require_authenticated_participant([])
      assert conn.halted
      assert redirected_to(conn)

      assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
               "You must log in to access this page."
    end

    test "stores the path to redirect to on GET", %{conn: conn} do
      halted_conn =
        %{conn | request_path: "/foo", query_string: ""}
        |> fetch_flash()
        |> ParticipantAuth.require_authenticated_participant([])

      assert halted_conn.halted
      assert get_session(halted_conn, :participant_return_to) == "/foo"

      halted_conn =
        %{conn | request_path: "/foo", query_string: "bar=baz"}
        |> fetch_flash()
        |> ParticipantAuth.require_authenticated_participant([])

      assert halted_conn.halted
      assert get_session(halted_conn, :participant_return_to) == "/foo?bar=baz"

      halted_conn =
        %{conn | request_path: "/foo?bar", method: "POST"}
        |> fetch_flash()
        |> ParticipantAuth.require_authenticated_participant([])

      assert halted_conn.halted
      refute get_session(halted_conn, :participant_return_to)
    end

    test "does not redirect if participant is authenticated", %{
      conn: conn,
      participant: participant
    } do
      conn =
        conn
        |> assign(:current_participant, participant)
        |> ParticipantAuth.require_authenticated_participant([])

      refute conn.halted
      refute conn.status
    end
  end
end

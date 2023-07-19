defmodule MayIsBikeMonthWeb.AdminControllerTest do
  use MayIsBikeMonthWeb.ConnCase, async: true

  import MayIsBikeMonth.ParticipantsFixtures
  alias MayIsBikeMonth.Participants

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, MayIsBikeMonthWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{conn: conn}
  end

  describe "/admin/dashboard" do
    test "redirects for non-admin", %{conn: conn} do
      participant = participant_fixture(strava_id: "123")
      assert Participants.admin?(participant) == false

      conn =
        conn
        |> put_session(:participant_id, participant.id)
        |> fetch_cookies()
        |> assign(:current_participant, participant)
        |> get("/admin/dashboard")

      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "admin"
    end

    test "renders", %{conn: conn} do
      participant = participant_fixture()
      assert Participants.admin?(participant)

      conn =
        conn
        |> put_session(:participant_id, participant.id)
        |> fetch_cookies()
        |> assign(:current_participant, participant)
        |> get("/admin/dashboard")

      response = html_response(conn, 200)
      assert response =~ "Kaffy"
    end
  end
end

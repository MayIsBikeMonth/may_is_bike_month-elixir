defmodule MayIsBikeMonthWeb.PageControllerTest do
  use MayIsBikeMonthWeb.ConnCase

  test "GET /", %{conn: conn} do
    competition = MayIsBikeMonth.CompetitionsFixtures.competition_fixture()

    competition_participant =
      MayIsBikeMonth.CompetitionParticipantsFixtures.competition_participant_fixture(
        competition_id: competition.id
      )

    assert competition_participant.competition_id == competition.id
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "May is Bike Month"
  end

  test "GET /update_strava", %{conn: conn} do
    competition = MayIsBikeMonth.CompetitionsFixtures.competition_fixture()

    competition_participant =
      MayIsBikeMonth.CompetitionParticipantsFixtures.competition_participant_fixture(
        competition_id: competition.id
      )

    assert competition_participant.competition_id == competition.id
    conn = get(conn, ~p"/update_strava")
    body = json_response(conn, 200)
    assert "success" in body["message"]
  end
end

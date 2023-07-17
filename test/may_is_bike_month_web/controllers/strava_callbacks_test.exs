defmodule MayIsBikeMonthWeb.StravaCallbackTest do
  use MayIsBikeMonthWeb.ConnCase, async: true

  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias MayIsBikeMonth.Participants

  setup do
    ExVCR.Config.cassette_library_dir("test/support/vcr_cassettes")

    ExVCR.Config.filter_sensitive_data(
      MayIsBikeMonth.config([:strava, :client_secret]),
      "STRAVA_SECRET"
    )

    HTTPoison.start()
    :ok
  end

  test "callback with valid token", %{conn: conn} do
    use_cassette "exchange_access_token-success" do
      params = %{"code" => "valid-code"}

      assert Participants.get_participant_by_strava_id("2430215") == nil
      assert Participants.list_strava_tokens() == []

      conn = get(conn, ~p"/oauth/callbacks/strava?#{params}")

      assert redirected_to(conn, 302) == "/"

      assert %Participants.Participant{} =
               participant = Participants.get_participant_by_strava_id(2_430_215)

      assert participant.display_name == "sethherr"

      assert Enum.count(Participants.list_strava_tokens()) == 1
      strava_token = Participants.strava_token_for_participant(participant)
      assert strava_token.access_token == "xxxxxxx"
      assert strava_token.refresh_token == "yyyyyyy"
    end
  end

  test "existing competition, callback with valid token, creates competition_participant", %{
    conn: conn
  } do
    competition = MayIsBikeMonth.CompetitionsFixtures.competition_fixture()
    assert MayIsBikeMonth.CompetitionParticipants.list_competition_participants() == []
    assert competition.active == false

    use_cassette "exchange_access_token-success" do
      params = %{"code" => "valid-code"}

      assert Participants.get_participant_by_strava_id("2430215") == nil
      assert Participants.list_strava_tokens() == []

      conn = get(conn, ~p"/oauth/callbacks/strava?#{params}")

      assert redirected_to(conn, 302) == "/"

      assert %Participants.Participant{} =
               participant = Participants.get_participant_by_strava_id(2_430_215)

      assert participant.display_name == "sethherr"

      assert Enum.count(Participants.list_strava_tokens()) == 1
      strava_token = Participants.strava_token_for_participant(participant)
      assert strava_token.access_token == "xxxxxxx"
      assert strava_token.refresh_token == "yyyyyyy"

      assert length(MayIsBikeMonth.CompetitionParticipants.list_competition_participants()) == 1

      competition_participant =
        MayIsBikeMonth.CompetitionParticipants.list_competition_participants() |> List.first()

      assert competition_participant.competition_id == competition.id
      assert competition_participant.participant_id == participant.id
      assert competition_participant.include_in_competition == true
    end
  end
end

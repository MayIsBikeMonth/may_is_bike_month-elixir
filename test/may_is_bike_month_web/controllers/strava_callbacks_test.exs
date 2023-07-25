defmodule MayIsBikeMonthWeb.StravaCallbackTest do
  use MayIsBikeMonthWeb.ConnCase, async: true

  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias MayIsBikeMonth.{CompetitionParticipants, CompetitionActivities, Participants}

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
    assert CompetitionParticipants.list_competition_participants() == []
    assert competition.active == false

    # NOTE: Manually edited cassette to prevent expiration - updated expires_at with
    # DateTime.to_unix(~U[2030-06-25 20:29:00Z])
    use_cassette "exchange_access_token-competition_participant" do
      params = %{"code" => "xxxxyyyy"}

      assert Participants.get_participant_by_strava_id("2430215") == nil
      assert Participants.list_strava_tokens() == []

      conn = get(conn, ~p"/oauth/callbacks/strava?#{params}")

      assert redirected_to(conn, 302) == "/"
      assert conn.assigns.flash == %{"info" => "Welcome sethherr"}

      assert %Participants.Participant{} =
               participant = Participants.get_participant_by_strava_id(2_430_215)

      assert conn.assigns.current_participant.id == participant.id
      assert participant.display_name == "sethherr"

      assert Enum.count(Participants.list_strava_tokens()) == 1
      strava_token = Participants.strava_token_for_participant(participant)
      assert strava_token.access_token == "xxxxxxx"
      assert strava_token.refresh_token == "yyyyyyy"

      assert length(CompetitionParticipants.list_competition_participants()) == 1

      competition_participant =
        CompetitionParticipants.list_competition_participants() |> List.first()

      assert Enum.count(CompetitionActivities.list_competition_activities()) == 19

      assert competition_participant.competition_id == competition.id
      assert competition_participant.participant_id == participant.id
      assert competition_participant.include_in_competition == true
      assert competition_participant.score == 13.99999892104254
    end
  end

  test "existing competition_participant, callback with valid token", %{
    conn: conn
  } do
    competition = MayIsBikeMonth.CompetitionsFixtures.competition_fixture()

    competition_participant =
      MayIsBikeMonth.CompetitionParticipantsFixtures.competition_participant_fixture(
        competition_id: competition.id
      )

    assert competition_participant.score == 0
    assert Enum.count(CompetitionParticipants.list_competition_participants()) == 1

    use_cassette "exchange_access_token-competition_participant" do
      params = %{"code" => "xxxxyyyy"}
      conn = get(conn, ~p"/oauth/callbacks/strava?#{params}")

      assert redirected_to(conn, 302) == "/"
      assert conn.assigns.flash == %{"info" => "Welcome some strava_username"}
      assert conn.assigns.current_participant.id == competition_participant.participant_id

      assert Enum.count(Participants.list_strava_tokens()) == 1
      assert Enum.count(CompetitionParticipants.list_competition_participants()) == 1
      # Reload competition_participant
      competition_participant =
        CompetitionParticipants.list_competition_participants() |> List.first()

      assert competition_participant.competition_id == competition.id
      assert competition_participant.include_in_competition == true
      assert competition_participant.score == 13.99999892104254
    end
  end
end

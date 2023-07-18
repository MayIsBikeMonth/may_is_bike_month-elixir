defmodule MayIsBikeMonth.StravaRequestsTest do
  use MayIsBikeMonth.DataCase

  alias MayIsBikeMonth.{
    CompetitionActivities,
    CompetitionParticipants,
    StravaRequests,
    StravaRequests.StravaRequest
  }

  import MayIsBikeMonth.{
    CompetitionsFixtures,
    CompetitionParticipantsFixtures,
    ParticipantsFixtures,
    StravaRequestsFixtures,
    StravaTokensFixtures
  }

  describe "strava_requests" do
    @invalid_attrs %{status: nil, kind: nil}

    test "list_strava_requests/0 returns all strava_requests" do
      strava_request = strava_request_fixture()
      assert StravaRequests.list_strava_requests() == [strava_request]

      sr = Enum.at(StravaRequests.list_strava_requests_load_participant(), 0)
      assert sr.participant.display_name == "some strava_username"
    end

    test "get_strava_request!/1 returns the strava_request with given id" do
      strava_request = strava_request_fixture()
      assert StravaRequests.get_strava_request!(strava_request.id) == strava_request
    end

    test "create_strava_request/1 with valid data creates a strava_request" do
      participant = participant_fixture()

      valid_attrs = %{
        error_response: %{},
        parameters: %{},
        status: 200,
        kind: :get_activities,
        participant_id: participant.id
      }

      assert {:ok, %StravaRequest{} = strava_request} =
               StravaRequests.create_strava_request(valid_attrs)

      assert strava_request.error_response == %{}
      assert strava_request.parameters == %{}
      assert strava_request.status == 200
      assert strava_request.kind == :get_activities
      assert strava_request.participant_id == participant.id
    end

    test "create_strava_request/1 with error_response creates a strava_request" do
      participant = participant_fixture()

      valid_attrs = %{
        error_response: %{"error" => ["something", "Stuff"]},
        parameters: %{},
        status: 400,
        kind: :get_activities,
        participant_id: participant.id
      }

      assert {:ok, %StravaRequest{} = strava_request} =
               StravaRequests.create_strava_request(valid_attrs)

      assert strava_request.error_response == valid_attrs[:error_response]
      assert strava_request.parameters == %{}
      assert strava_request.status == 400
      assert strava_request.kind == :get_activities
      assert strava_request.participant_id == participant.id
    end

    test "create_strava_request/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = StravaRequests.create_strava_request(@invalid_attrs)
    end

    test "delete_strava_request/1 deletes the strava_request" do
      strava_request = strava_request_fixture()
      assert {:ok, %StravaRequest{}} = StravaRequests.delete_strava_request(strava_request)

      assert_raise Ecto.NoResultsError, fn ->
        StravaRequests.get_strava_request!(strava_request.id)
      end
    end
  end

  describe "strava_requests with vcr" do
    use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

    test "request_participant_activities_for_competition/2 returns the participant's activities" do
      setup_vcr()

      use_cassette "get_activities-for_competition-success" do
        competition = competition_fixture()
        participant = participant_fixture()
        strava_token_fixture(%{"participant_id" => participant.id, "access_token" => "xxxxxxxx"})

        assert StravaRequests.list_strava_requests() == []

        {:ok, activities} =
          StravaRequests.request_participant_activities_for_competition(participant, competition)

        assert Enum.count(activities) == 19

        strava_request = StravaRequests.list_strava_requests() |> Enum.at(0)
        assert strava_request.status == 200
        assert strava_request.error_response == %{}
        assert strava_request.participant_id == participant.id
        assert strava_request.kind == :get_activities

        assert strava_request.parameters ==
                 StravaRequests.parameters_for_activities_for_competition(competition)
      end
    end

    test "create_or_update_competition_activities/1 creates the competition activities" do
      setup_vcr()
      competition_participant = competition_participant_fixture()

      strava_token_fixture(%{
        "participant_id" => competition_participant.participant_id,
        "access_token" => "xxxxxxxxx"
      })

      use_cassette "create_or_update_competition_activities-success" do
        assert StravaRequests.list_strava_requests() == []
        assert competition_participant.score == 0

        assert Enum.count(CompetitionActivities.list_competition_activities()) == 0

        {:ok, _activities} =
          StravaRequests.update_competition_participant_activities(competition_participant)

        assert Enum.count(CompetitionActivities.list_competition_activities()) == 19

        competition_participant =
          CompetitionParticipants.get_competition_participant!(competition_participant.id)

        assert competition_participant.score == 13.99999892104254
      end
    end
  end
end

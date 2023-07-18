defmodule MayIsBikeMonth.StravaRequestsTest do
  use MayIsBikeMonth.DataCase

  alias MayIsBikeMonth.StravaRequests

  describe "strava_requests" do
    alias MayIsBikeMonth.StravaRequests.StravaRequest

    import MayIsBikeMonth.ParticipantsFixtures
    import MayIsBikeMonth.StravaRequestsFixtures

    @invalid_attrs %{status: nil, type: nil}

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
        options: %{},
        status: 200,
        type: :get_activities,
        participant_id: participant.id
      }

      assert {:ok, %StravaRequest{} = strava_request} =
               StravaRequests.create_strava_request(valid_attrs)

      assert strava_request.error_response == %{}
      assert strava_request.options == %{}
      assert strava_request.status == 200
      assert strava_request.type == :get_activities
      assert strava_request.participant_id == participant.id
    end

    test "create_strava_request/1 with error_response creates a strava_request" do
      participant = participant_fixture()

      valid_attrs = %{
        error_response: %{"error" => ["something", "Stuff"]},
        options: %{},
        status: 400,
        type: :get_activities,
        participant_id: participant.id
      }

      assert {:ok, %StravaRequest{} = strava_request} =
               StravaRequests.create_strava_request(valid_attrs)

      assert strava_request.error_response == valid_attrs[:error_response]
      assert strava_request.options == %{}
      assert strava_request.status == 400
      assert strava_request.type == :get_activities
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
end

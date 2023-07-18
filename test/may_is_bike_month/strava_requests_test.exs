defmodule MayIsBikeMonth.StravaRequestsTest do
  use MayIsBikeMonth.DataCase

  alias MayIsBikeMonth.StravaRequests

  describe "strava_requests" do
    alias MayIsBikeMonth.StravaRequests.StravaRequest

    import MayIsBikeMonth.StravaRequestsFixtures

    @invalid_attrs %{error_response: nil, options: nil, status: nil, type: nil}

    test "list_strava_requests/0 returns all strava_requests" do
      strava_request = strava_request_fixture()
      assert StravaRequests.list_strava_requests() == [strava_request]
    end

    test "get_strava_request!/1 returns the strava_request with given id" do
      strava_request = strava_request_fixture()
      assert StravaRequests.get_strava_request!(strava_request.id) == strava_request
    end

    test "create_strava_request/1 with valid data creates a strava_request" do
      valid_attrs = %{error_response: %{}, options: %{}, status: 42, type: 42}

      assert {:ok, %StravaRequest{} = strava_request} = StravaRequests.create_strava_request(valid_attrs)
      assert strava_request.error_response == %{}
      assert strava_request.options == %{}
      assert strava_request.status == 42
      assert strava_request.type == 42
    end

    test "create_strava_request/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = StravaRequests.create_strava_request(@invalid_attrs)
    end

    test "update_strava_request/2 with valid data updates the strava_request" do
      strava_request = strava_request_fixture()
      update_attrs = %{error_response: %{}, options: %{}, status: 43, type: 43}

      assert {:ok, %StravaRequest{} = strava_request} = StravaRequests.update_strava_request(strava_request, update_attrs)
      assert strava_request.error_response == %{}
      assert strava_request.options == %{}
      assert strava_request.status == 43
      assert strava_request.type == 43
    end

    test "update_strava_request/2 with invalid data returns error changeset" do
      strava_request = strava_request_fixture()
      assert {:error, %Ecto.Changeset{}} = StravaRequests.update_strava_request(strava_request, @invalid_attrs)
      assert strava_request == StravaRequests.get_strava_request!(strava_request.id)
    end

    test "delete_strava_request/1 deletes the strava_request" do
      strava_request = strava_request_fixture()
      assert {:ok, %StravaRequest{}} = StravaRequests.delete_strava_request(strava_request)
      assert_raise Ecto.NoResultsError, fn -> StravaRequests.get_strava_request!(strava_request.id) end
    end

    test "change_strava_request/1 returns a strava_request changeset" do
      strava_request = strava_request_fixture()
      assert %Ecto.Changeset{} = StravaRequests.change_strava_request(strava_request)
    end
  end
end

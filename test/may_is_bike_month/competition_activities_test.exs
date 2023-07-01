defmodule MayIsBikeMonth.CompetitionActivitiesTest do
  use MayIsBikeMonth.DataCase

  alias MayIsBikeMonth.CompetitionActivities

  describe "competition_activities" do
    alias MayIsBikeMonth.CompetitionActivities.CompetitionActivity

    import MayIsBikeMonth.CompetitionActivitiesFixtures

    @invalid_attrs %{display_name: nil, distance_meters: nil, duration_seconds: nil, elevation_meters: nil, end_date: nil, include_in_competition: nil, start_at: nil, start_date: nil, strava_data: nil, strava_id: nil, timezone: nil}

    test "list_competition_activities/0 returns all competition_activities" do
      competition_activity = competition_activity_fixture()
      assert CompetitionActivities.list_competition_activities() == [competition_activity]
    end

    test "get_competition_activity!/1 returns the competition_activity with given id" do
      competition_activity = competition_activity_fixture()
      assert CompetitionActivities.get_competition_activity!(competition_activity.id) == competition_activity
    end

    test "create_competition_activity/1 with valid data creates a competition_activity" do
      valid_attrs = %{display_name: "some display_name", distance_meters: 42, duration_seconds: 42, elevation_meters: 42, end_date: ~D[2023-06-30], include_in_competition: true, start_at: ~U[2023-06-30 22:57:00Z], start_date: ~D[2023-06-30], strava_data: %{}, strava_id: "some strava_id", timezone: "some timezone"}

      assert {:ok, %CompetitionActivity{} = competition_activity} = CompetitionActivities.create_competition_activity(valid_attrs)
      assert competition_activity.display_name == "some display_name"
      assert competition_activity.distance_meters == 42
      assert competition_activity.duration_seconds == 42
      assert competition_activity.elevation_meters == 42
      assert competition_activity.end_date == ~D[2023-06-30]
      assert competition_activity.include_in_competition == true
      assert competition_activity.start_at == ~U[2023-06-30 22:57:00Z]
      assert competition_activity.start_date == ~D[2023-06-30]
      assert competition_activity.strava_data == %{}
      assert competition_activity.strava_id == "some strava_id"
      assert competition_activity.timezone == "some timezone"
    end

    test "create_competition_activity/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CompetitionActivities.create_competition_activity(@invalid_attrs)
    end

    test "update_competition_activity/2 with valid data updates the competition_activity" do
      competition_activity = competition_activity_fixture()
      update_attrs = %{display_name: "some updated display_name", distance_meters: 43, duration_seconds: 43, elevation_meters: 43, end_date: ~D[2023-07-01], include_in_competition: false, start_at: ~U[2023-07-01 22:57:00Z], start_date: ~D[2023-07-01], strava_data: %{}, strava_id: "some updated strava_id", timezone: "some updated timezone"}

      assert {:ok, %CompetitionActivity{} = competition_activity} = CompetitionActivities.update_competition_activity(competition_activity, update_attrs)
      assert competition_activity.display_name == "some updated display_name"
      assert competition_activity.distance_meters == 43
      assert competition_activity.duration_seconds == 43
      assert competition_activity.elevation_meters == 43
      assert competition_activity.end_date == ~D[2023-07-01]
      assert competition_activity.include_in_competition == false
      assert competition_activity.start_at == ~U[2023-07-01 22:57:00Z]
      assert competition_activity.start_date == ~D[2023-07-01]
      assert competition_activity.strava_data == %{}
      assert competition_activity.strava_id == "some updated strava_id"
      assert competition_activity.timezone == "some updated timezone"
    end

    test "update_competition_activity/2 with invalid data returns error changeset" do
      competition_activity = competition_activity_fixture()
      assert {:error, %Ecto.Changeset{}} = CompetitionActivities.update_competition_activity(competition_activity, @invalid_attrs)
      assert competition_activity == CompetitionActivities.get_competition_activity!(competition_activity.id)
    end

    test "delete_competition_activity/1 deletes the competition_activity" do
      competition_activity = competition_activity_fixture()
      assert {:ok, %CompetitionActivity{}} = CompetitionActivities.delete_competition_activity(competition_activity)
      assert_raise Ecto.NoResultsError, fn -> CompetitionActivities.get_competition_activity!(competition_activity.id) end
    end

    test "change_competition_activity/1 returns a competition_activity changeset" do
      competition_activity = competition_activity_fixture()
      assert %Ecto.Changeset{} = CompetitionActivities.change_competition_activity(competition_activity)
    end
  end
end

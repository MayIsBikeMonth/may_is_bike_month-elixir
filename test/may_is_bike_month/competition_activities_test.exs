defmodule MayIsBikeMonth.CompetitionActivitiesTest do
  use MayIsBikeMonth.DataCase

  alias MayIsBikeMonth.CompetitionActivities

  describe "competition_activities" do
    alias MayIsBikeMonth.CompetitionActivities.CompetitionActivity

    import MayIsBikeMonth.CompetitionActivitiesFixtures
    import MayIsBikeMonth.CompetitionParticipantsFixtures

    # @invalid_attrs %{
    #   strava_id: nil,
    #   competition_participant: nil
    # }

    def get_strava_data() do
      activity_path =
        Path.expand("../support/fixtures/strava_activity.json", __DIR__)
        |> File.read!()
        |> Jason.decode!()
    end

    # test "list_competition_activities/0 returns all competition_activities" do
    #   competition_activity = competition_activity_fixture()
    #   assert CompetitionActivities.list_competition_activities() == [competition_activity]
    # end

    # test "get_competition_activity!/1 returns the competition_activity with given id" do
    #   competition_activity = competition_activity_fixture()

    #   assert CompetitionActivities.get_competition_activity!(competition_activity.id) ==
    #            competition_activity
    # end

    test "create_competition_activity/1 with valid data creates a competition_activity" do
      strava_data = get_strava_data()
      competition_participant = competition_participant_fixture()

      valid_attrs = %{
        strava_data: strava_data,
        competition_participant_id: competition_participant.id
      }

      target_strava_attrs = %{
        strava_id: "9073105197",
        start_date: ~D[2023-05-14],
        end_date: nil,
        timezone: "America/Los_Angeles",
        start_at: ~U[2023-05-14 19:08:57Z],
        display_name: "Craig road ride",
        distance_meters: 80961.7,
        elevation_meters: 917.0,
        moving_seconds: 13530
      }

      assert CompetitionActivities.strava_attrs_from_data(strava_data) == target_strava_attrs

      assert {:ok, %CompetitionActivity{} = competition_activity} =
               CompetitionActivities.create_from_strava_data(
                 competition_participant.id,
                 strava_data
               )

      assert competition_activity.competition_participant_id == competition_participant.id

      ignored_keys = [
        "map",
        "segment_efforts",
        "splits_metric",
        "splits_standard",
        "laps",
        "stats_visibility"
      ]

      assert competition_activity.strava_data == Map.drop(strava_data, ignored_keys)

      assert Map.take(competition_activity, Map.keys(target_strava_attrs)) == target_strava_attrs

      assert competition_activity.include_in_competition == true
    end

    # test "create_competition_activity/1 with invalid data returns error changeset" do
    #   assert {:error, %Ecto.Changeset{}} =
    #            CompetitionActivities.create_competition_activity(@invalid_attrs)
    # end

    #   test "update_competition_activity/2 with valid data updates the competition_activity" do
    #     competition_activity = competition_activity_fixture()

    #     update_attrs = %{
    #       display_name: "some updated display_name",
    #     }

    #     assert {:ok, %CompetitionActivity{} = competition_activity} =
    #              CompetitionActivities.update_competition_activity(
    #                competition_activity,
    #                update_attrs
    #              )

    #     assert competition_activity.strava_data == %{}
    #     assert competition_activity.strava_id == "some updated strava_id"
    #     assert competition_activity.timezone == "some updated timezone"
    #   end

    #   test "update_competition_activity/2 with invalid data returns error changeset" do
    #     competition_activity = competition_activity_fixture()

    #     assert {:error, %Ecto.Changeset{}} =
    #              CompetitionActivities.update_competition_activity(
    #                competition_activity,
    #                @invalid_attrs
    #              )

    #     assert competition_activity ==
    #              CompetitionActivities.get_competition_activity!(competition_activity.id)
    #   end

    #   test "delete_competition_activity/1 deletes the competition_activity" do
    #     competition_activity = competition_activity_fixture()

    #     assert {:ok, %CompetitionActivity{}} =
    #              CompetitionActivities.delete_competition_activity(competition_activity)

    #     assert_raise Ecto.NoResultsError, fn ->
    #       CompetitionActivities.get_competition_activity!(competition_activity.id)
    #     end
    #   end

    #   test "change_competition_activity/1 returns a competition_activity changeset" do
    #     competition_activity = competition_activity_fixture()

    #     assert %Ecto.Changeset{} =
    #              CompetitionActivities.change_competition_activity(competition_activity)
    #   end
  end
end

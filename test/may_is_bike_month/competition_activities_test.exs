defmodule MayIsBikeMonth.CompetitionActivitiesTest do
  use MayIsBikeMonth.DataCase

  alias MayIsBikeMonth.CompetitionActivities

  describe "competition_activities" do
    alias MayIsBikeMonth.CompetitionActivities.CompetitionActivity

    import MayIsBikeMonth.CompetitionActivitiesFixtures
    import MayIsBikeMonth.CompetitionParticipantsFixtures

    @invalid_attrs %{
      strava_id: nil,
      competition_participant: nil
    }

    # TODO: make this not as hacky
    def pluck_ids(ecto_list) do
      ecto_list
      |> Enum.map(fn obj -> obj.id end)
    end

    test "list_competition_activities/0 returns all competition_activities" do
      competition_activity = competition_activity_fixture_from_strava_data()
      assert CompetitionActivities.list_competition_activities() == [competition_activity]
    end

    test "list_competition_activities/2 filters by competition_participant_id and period" do
      competition_activity1 = competition_activity_fixture(start_at: ~U[2023-05-24 14:08:57Z])
      assert competition_activity1.id != nil
      participant = MayIsBikeMonth.ParticipantsFixtures.participant_fixture(strava_id: "123")
      competition_participant = competition_participant_fixture(participant_id: participant.id)

      competition_activity2 =
        competition_activity_fixture(%{
          strava_id: "69",
          start_at: ~U[2023-05-28 06:08:57Z],
          moving_seconds: 129_600,
          competition_participant_id: competition_participant.id,
          include_in_competition: false
        })

      assert competition_activity2.competition_participant_id == competition_participant.id
      assert competition_activity2.strava_id == "69"
      assert competition_activity2.start_date == ~D[2023-05-27]
      assert competition_activity2.end_date == ~D[2023-05-29]

      competition_activity3 =
        competition_activity_fixture(
          strava_id: "7000",
          competition_participant: competition_participant,
          start_at: ~U[2023-05-23 19:08:57Z]
        )

      assert competition_activity3.competition_participant_id == competition_participant.id
      assert competition_activity3.start_date == ~D[2023-05-23]
      assert competition_activity3.end_date == ~D[2023-05-23]

      competition_activity4 =
        competition_activity_fixture(
          start_at: ~U[2023-05-30 14:08:57Z],
          strava_id: "42134",
          competition_participant: competition_participant
        )

      assert competition_activity4.start_date == ~D[2023-05-30]

      # Filtering by period
      assert pluck_ids(
               CompetitionActivities.list_competition_activities(%{
                 start_date: ~D[2023-05-22],
                 end_date: ~D[2023-05-28]
               })
             ) ==
               [competition_activity2.id, competition_activity1.id, competition_activity3.id]

      # Filtering by competition_participant
      assert pluck_ids(
               CompetitionActivities.list_competition_activities(%{
                 competition_participant_id: competition_participant.id
               })
             ) == [competition_activity4.id, competition_activity2.id, competition_activity3.id]

      # Filtering by competition_participant and period
      assert pluck_ids(
               CompetitionActivities.list_competition_activities(%{
                 competition_participant_id: competition_participant.id,
                 start_date: ~D[2023-05-22],
                 end_date: ~D[2023-05-28]
               })
             ) == [competition_activity2.id, competition_activity3.id]

      # Filtering by next period - includes the activity that crosses between periods
      assert pluck_ids(
               CompetitionActivities.list_competition_activities(%{
                 start_date: ~D[2023-05-29],
                 end_date: ~D[2023-05-31]
               })
             ) ==
               [competition_activity4.id, competition_activity2.id]

      assert pluck_ids(
               CompetitionActivities.list_competition_activities(%{
                 start_date: ~D[2023-05-29],
                 end_date: ~D[2023-05-31],
                 competition_participant_id: competition_participant.id,
                 include_in_competition: true
               })
             ) ==
               [competition_activity4.id]
    end

    test "get_competition_activity!/1 returns the competition_activity with given id" do
      competition_activity = competition_activity_fixture_from_strava_data()

      assert CompetitionActivities.get_competition_activity!(competition_activity.id) ==
               competition_activity
    end

    test "create_competition_activity/1 with valid data creates a competition_activity" do
      strava_data = load_strava_activity_data_fixture()
      competition_participant = competition_participant_fixture()

      target_strava_attrs = %{
        strava_id: "9073105197",
        start_date: ~D[2023-05-14],
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
                 competition_participant,
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
      assert competition_activity.end_date == ~D[2023-05-14]
    end

    test "parse_strava_timezone/1 parses strava timezone strings" do
      assert CompetitionActivities.parse_strava_timezone("(GMT-08:00) America/Los_Angeles") ==
               "America/Los_Angeles"
    end

    test "create_competition_activity/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               CompetitionActivities.create_competition_activity(@invalid_attrs)
    end

    test "update_competition_activity/2 with valid data updates the competition_activity" do
      competition_activity = competition_activity_fixture_from_strava_data()

      update_attrs = %{
        display_name: "some updated display_name",
        include_in_competition: false
      }

      assert {:ok, %CompetitionActivity{} = competition_activity} =
               CompetitionActivities.update_competition_activity(
                 competition_activity,
                 update_attrs
               )

      assert competition_activity.display_name == "some updated display_name"
      assert competition_activity.include_in_competition == false
    end

    test "delete_competition_activity/1 deletes the competition_activity" do
      competition_activity = competition_activity_fixture_from_strava_data()

      assert {:ok, %CompetitionActivity{}} =
               CompetitionActivities.delete_competition_activity(competition_activity)

      assert_raise Ecto.NoResultsError, fn ->
        CompetitionActivities.get_competition_activity!(competition_activity.id)
      end
    end

    test "change_competition_activity/1 returns a competition_activity changeset" do
      competition_activity = competition_activity_fixture_from_strava_data()

      assert %Ecto.Changeset{} =
               CompetitionActivities.change_competition_activity(competition_activity)
    end

    test "unique_constraint competition_participant_id strava_id" do
      competition_activity = competition_activity_fixture()

      IO.inspect(Map.take(competition_activity, [:competition_participant_id, :strava_id]))

      assert {:error, %Ecto.Changeset{}} =
               CompetitionActivities.create_competition_activity(%{
                 competition_participant_id: competition_activity.competition_participant_id,
                 strava_id: competition_activity.strava_id,
                 strava_data: %{"type" => "Ride"}
               })
    end

    test "calculated_include_in_competition?/2 returns true for valid types" do
      competition_participant = competition_participant_fixture()
      assert competition_participant.include_in_competition == true

      assert CompetitionActivities.calculated_include_in_competition?(competition_participant, %{
               "type" => "Ride",
               "visibility" => "everyone",
               "distance" => 4000
             }) == true

      assert CompetitionActivities.calculated_include_in_competition?(competition_participant, %{
               "type" => "Velomobile",
               "visibility" => "everyone",
               "distance" => 4000
             }) == true

      assert CompetitionActivities.calculated_include_in_competition?(competition_participant, %{
               "type" => "VirtualRide",
               "visibility" => "everyone",
               "distance" => 4000
             }) == false
    end

    test "calculated_include_in_competition?/2 returns true for valid visibility" do
      competition_participant = competition_participant_fixture()

      assert CompetitionActivities.calculated_include_in_competition?(competition_participant, %{
               "type" => "Ride",
               "visibility" => "everyone",
               "distance" => 4000
             }) == true

      assert CompetitionActivities.calculated_include_in_competition?(competition_participant, %{
               "type" => "Ride",
               "visibility" => "followers_only",
               "distance" => 4000
             }) == true

      assert CompetitionActivities.calculated_include_in_competition?(competition_participant, %{
               "type" => "Ride",
               "visibility" => "only_me",
               "distance" => 4000
             }) == false
    end

    test "calculated_include_in_competition?/2 returns true for valid distances" do
      competition_participant = competition_participant_fixture()

      assert CompetitionActivities.calculated_include_in_competition?(competition_participant, %{
               "type" => "Ride",
               "visibility" => "everyone",
               "distance" => 3300
             }) == true

      assert CompetitionActivities.calculated_include_in_competition?(competition_participant, %{
               "type" => "Ride",
               "visibility" => "everyone",
               "distance" => 2000
             }) == false
    end

    test "activity_dates/3 returns single date for a short ride" do
      short_ride_dates =
        CompetitionActivities.activity_dates(
          ~U[2023-05-14 03:08:57Z],
          "America/Los_Angeles",
          8280
        )

      assert short_ride_dates == [~D[2023-05-13]]
    end

    test "activity_dates/3 returns list of dates for a long ride" do
      short_ride_dates =
        CompetitionActivities.activity_dates(
          ~U[2023-05-28 06:08:57Z],
          "America/Los_Angeles",
          129_600
        )

      assert short_ride_dates == [~D[2023-05-27], ~D[2023-05-28], ~D[2023-05-29]]
    end

    test "competition_participant_period_data/1" do
      competition_activity = competition_activity_fixture_from_strava_data()

      assert CompetitionActivities.score_data(competition_activity) == %{
               "distance_meters" => 80961.7,
               "elevation_meters" => 917.0,
               "strava_id" => "9073105197",
               "display_name" => "Craig road ride",
               "dates" => MapSet.new([~D[2023-05-14]])
             }
    end
  end
end

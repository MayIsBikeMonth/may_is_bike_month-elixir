defmodule MayIsBikeMonth.CompetitionParticipantsTest do
  use MayIsBikeMonth.DataCase

  alias MayIsBikeMonth.CompetitionParticipants

  describe "competition_participants" do
    alias MayIsBikeMonth.CompetitionParticipants.CompetitionParticipant

    import MayIsBikeMonth.CompetitionParticipantsFixtures
    import MayIsBikeMonth.CompetitionsFixtures
    import MayIsBikeMonth.CompetitionActivitiesFixtures
    import MayIsBikeMonth.ParticipantsFixtures

    @invalid_attrs %{participant_id: nil, competition_id: nil}

    test "list_competition_participants/0 returns all competition_participants" do
      competition_participant = competition_participant_fixture()
      assert CompetitionParticipants.list_competition_participants() == [competition_participant]

      competition =
        MayIsBikeMonth.Competitions.get_competition!(competition_participant.competition_id)

      assert CompetitionParticipants.for_competition(competition) == [competition_participant]
    end

    test "get_competition_participant!/1 returns the competition_participant with given id" do
      competition_participant = competition_participant_fixture()

      assert CompetitionParticipants.get_competition_participant!(competition_participant.id) ==
               competition_participant

      assert competition_participant.included_activity_types == nil
    end

    test "competition_fixture uses passed in competition and participant" do
      competition = competition_fixture()
      participant = participant_fixture()

      competition_participant =
        competition_participant_fixture(%{
          competition_id: competition.id,
          participant_id: participant.id
        })

      assert competition_participant.competition_id == competition.id
      assert competition_participant.participant_id == participant.id
      assert competition_participant.participant == participant
    end

    test "create_competition_participant/1 with valid data creates a competition_participant" do
      competition = competition_fixture()
      participant = participant_fixture()

      valid_attrs = %{
        include_in_competition: true,
        competition_id: competition.id,
        participant_id: participant.id
      }

      assert {:ok, %CompetitionParticipant{} = competition_participant} =
               CompetitionParticipants.create_competition_participant(valid_attrs)

      assert competition_participant.include_in_competition == true
      assert competition_participant.score == 0
      assert competition_participant.competition_id == competition.id
      assert competition_participant.participant_id == participant.id
      # Always return with participant
      assert competition_participant.participant == participant
    end

    test "create_competition_participant/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               CompetitionParticipants.create_competition_participant(@invalid_attrs)
    end

    test "update_competition_participant/2 with valid data updates the competition_participant" do
      competition_participant = competition_participant_fixture()
      update_attrs = %{include_in_competition: false}

      assert {:ok, %CompetitionParticipant{} = competition_participant} =
               CompetitionParticipants.update_competition_participant(
                 competition_participant,
                 update_attrs
               )

      assert competition_participant.include_in_competition == false
      assert competition_participant.score == 0
    end

    test "update_competition_participant/2 with invalid data returns error changeset" do
      competition_participant = competition_participant_fixture()

      assert {:error, %Ecto.Changeset{}} =
               CompetitionParticipants.update_competition_participant(
                 competition_participant,
                 @invalid_attrs
               )

      assert competition_participant ==
               CompetitionParticipants.get_competition_participant!(competition_participant.id)
    end

    test "delete_competition_participant/1 deletes the competition_participant" do
      competition_participant = competition_participant_fixture()

      assert {:ok, %CompetitionParticipant{}} =
               CompetitionParticipants.delete_competition_participant(competition_participant)

      assert_raise Ecto.NoResultsError, fn ->
        CompetitionParticipants.get_competition_participant!(competition_participant.id)
      end
    end

    test "change_competition_participant/1 returns a competition_participant changeset" do
      competition_participant = competition_participant_fixture()

      assert %Ecto.Changeset{} =
               CompetitionParticipants.change_competition_participant(competition_participant)
    end

    test "unique_constraint on strava_id and competition_id" do
      competition_participant = competition_participant_fixture()

      assert {:error, %Ecto.Changeset{} = changeset_with_error} =
               CompetitionParticipants.create_competition_participant(%{
                 participant_id: competition_participant.participant_id,
                 competition_id: competition_participant.competition_id
               })

      assert length(changeset_with_error.errors) == 1
      assert is_list(changeset_with_error.errors)
      {error_attribute, _} = List.first(changeset_with_error.errors)
      assert error_attribute == :participant_id_competition_id

      # But with a changed competition_id or participant_id, it works
      assert {:ok, _created_competition_participant} =
               CompetitionParticipants.create_competition_participant(%{
                 participant_id: competition_participant.participant_id,
                 competition_id: competition_fixture().id
               })

      assert {:ok, _created_competition_participant} =
               CompetitionParticipants.create_competition_participant(%{
                 participant_id: participant_fixture(strava_id: "3242452").id,
                 competition_id: competition_participant.competition_id
               })
    end

    test "included_activity_types/1 returns the default included_activity_types" do
      # Make this potentially configurable in the future - so someone who is injured or something can participate
      # For now, it's just a stub'
      competition_participant = competition_participant_fixture()

      assert CompetitionParticipants.included_activity_types(competition_participant) == [
               "Ride",
               "Velomobile",
               "Handcycle"
             ]
    end

    test "included_activity_type?/2 returns true for valid types" do
      competition_participant = competition_participant_fixture()

      assert CompetitionParticipants.included_activity_type?(competition_participant, "Ride")

      assert CompetitionParticipants.included_activity_type?(
               competition_participant,
               "Velomobile"
             )

      assert CompetitionParticipants.included_activity_type?(competition_participant, "Handcycle")

      assert CompetitionParticipants.included_activity_type?(
               competition_participant,
               "VirtualRide"
             ) ==
               false
    end

    test "included_distance?/2 returns true for valid distances" do
      competition_participant = competition_participant_fixture()

      assert CompetitionParticipants.included_distance?(competition_participant, "Ride")
    end

    test "period_activities_data/3 and scoring_data_for_period/1" do
      competition = competition_fixture(end_date: ~D[2023-05-31], start_date: ~D[2023-05-01])
      competition_participant = competition_participant_fixture(competition_id: competition.id)

      competition_activity =
        competition_activity_fixture(%{
          strava_id: "3",
          start_at: ~U[2023-05-28 06:08:57Z],
          moving_seconds: 129_600,
          competition_participant_id: competition_participant.id
        })

      assert competition_activity.start_date == ~D[2023-05-27]
      assert competition_activity.end_date == ~D[2023-05-29]

      empty_period_data = %{
        "dates" => [],
        "distance_meters" => 0,
        "elevation_meters" => 0,
        "activities" => []
      }

      period1_data =
        CompetitionParticipants.period_activities_data(
          competition_participant,
          ~D[2023-05-01],
          ~D[2023-05-07]
        )
        |> CompetitionParticipants.scoring_data_for_period()

      assert period1_data == empty_period_data

      period3_activity_data = %{
        "distance_meters" => 100_069.9,
        "elevation_meters" => 696.9,
        "display_name" => "Some bike ride",
        "strava_id" => "3",
        "dates" => [~D[2023-05-27], ~D[2023-05-28]],
        "starts_in_previous_period" => false
      }

      assert CompetitionParticipants.period_activities_data(
               competition_participant,
               ~D[2023-05-22],
               ~D[2023-05-28]
             ) == [period3_activity_data]

      period4_activity_data =
        Map.merge(period3_activity_data, %{
          "distance_meters" => 0,
          "elevation_meters" => 0,
          "starts_in_previous_period" => true,
          "dates" => [~D[2023-05-29]]
        })

      assert CompetitionParticipants.period_activities_data(
               competition_participant,
               ~D[2023-05-29],
               ~D[2023-05-31]
             ) == [period4_activity_data]

      assert CompetitionParticipants.scoring_data_for_period([period3_activity_data]) == %{
               "dates" => period3_activity_data["dates"],
               "distance_meters" => period3_activity_data["distance_meters"],
               "elevation_meters" => period3_activity_data["elevation_meters"],
               "activities" => [period3_activity_data]
             }

      assert CompetitionParticipants.scoring_data_for_period([period4_activity_data]) == %{
               "dates" => period4_activity_data["dates"],
               "distance_meters" => 0,
               "elevation_meters" => 0,
               "activities" => [period4_activity_data]
             }
    end

    test "calculate_scoring_periods/2 with multiple" do
      competition = competition_fixture(end_date: ~D[2023-05-31], start_date: ~D[2023-05-01])
      competition_participant = competition_participant_fixture(competition_id: competition.id)

      competition_activity_fixture(
        strava_id: "1",
        start_at: ~U[2023-05-01 14:08:57Z],
        competition_participant_id: competition_participant.id
      )

      competition_activity_fixture(%{
        strava_id: "2",
        start_at: ~U[2023-05-28 06:08:57Z],
        moving_seconds: 129_600,
        competition_participant_id: competition_participant.id
      })

      competition_activity_fixture(
        strava_id: "3",
        competition_participant: competition_participant,
        start_at: ~U[2023-05-23 19:08:57Z]
      )

      competition_activity_fixture(
        start_at: ~U[2023-05-29 14:08:57Z],
        strava_id: "4",
        competition_participant: competition_participant
      )

      scoring_periods =
        CompetitionParticipants.calculate_scoring_periods(competition_participant, competition)

      assert length(scoring_periods) == 5

      period5 = Enum.fetch!(scoring_periods, 4)

      assert Map.drop(period5, ["activities"]) == %{
               "dates" => [~D[2023-05-29]],
               "distance_meters" => 100_069.9,
               "elevation_meters" => 696.9
             }

      assert period5["activities"] == [
               %{
                 "distance_meters" => 0,
                 "elevation_meters" => 0,
                 "starts_in_previous_period" => true,
                 "display_name" => "Some bike ride",
                 "strava_id" => "2",
                 "dates" => [~D[2023-05-29]]
               },
               %{
                 "distance_meters" => 100_069.9,
                 "elevation_meters" => 696.9,
                 "starts_in_previous_period" => false,
                 "display_name" => "Some bike ride",
                 "strava_id" => "4",
                 "dates" => [~D[2023-05-29]]
               }
             ]

      scoring_data =
        CompetitionParticipants.calculate_scoring_data(competition_participant, competition)

      assert Map.keys(scoring_data) == [
               "dates",
               "distance_meters",
               "elevation_meters",
               "periods",
               "score"
             ]

      dates = Enum.to_list(scoring_data["dates"]) |> Enum.map(fn date -> "#{date}" end)

      assert dates == [
               "2023-05-01",
               "2023-05-23",
               "2023-05-27",
               "2023-05-28",
               "2023-05-29"
             ]

      assert scoring_data["distance_meters"] == 400_279.6
      assert scoring_data["elevation_meters"] == 2787.6

      assert CompetitionParticipants.calculate_score(
               Enum.to_list(scoring_data["dates"]),
               scoring_data["distance_meters"]
             ) == 5.99999750174628

      assert scoring_data["score"] == 5.99999750174628

      CompetitionParticipants.update_calculated_score(competition_participant)

      competition_participant =
        CompetitionParticipants.get_competition_participant!(competition_participant.id)

      assert competition_participant.score == 5.99999750174628
      assert Jason.encode!(competition_participant.score_data) == Jason.encode!(scoring_data)
    end
  end
end

defmodule MayIsBikeMonth.CompetitionParticipantsTest do
  use MayIsBikeMonth.DataCase

  alias MayIsBikeMonth.CompetitionParticipants

  describe "competition_participants" do
    alias MayIsBikeMonth.CompetitionParticipants.CompetitionParticipant

    import MayIsBikeMonth.CompetitionParticipantsFixtures

    @invalid_attrs %{participant_id: nil, competition_id: nil}

    test "list_competition_participants/0 returns all competition_participants" do
      competition_participant = competition_participant_fixture()
      assert CompetitionParticipants.list_competition_participants() == [competition_participant]
    end

    test "get_competition_participant!/1 returns the competition_participant with given id" do
      competition_participant = competition_participant_fixture()

      assert CompetitionParticipants.get_competition_participant!(competition_participant.id) ==
               competition_participant
    end

    test "create_competition_participant/1 with valid data creates a competition_participant" do
      competition = MayIsBikeMonth.CompetitionsFixtures.competition_fixture()
      participant = MayIsBikeMonth.ParticipantsFixtures.participant_fixture()

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
  end
end

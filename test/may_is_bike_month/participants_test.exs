defmodule MayIsBikeMonth.ParticipantsTest do
  use MayIsBikeMonth.DataCase

  alias MayIsBikeMonth.Participants

  describe "participants" do
    alias MayIsBikeMonth.Participants.Participant

    import MayIsBikeMonth.ParticipantsFixtures

    @invalid_attrs %{
      display_name: nil,
      first_name: nil,
      image_url: nil,
      last_name: nil,
      strava_auth: nil,
      strava_id: nil,
      strava_username: nil
    }

    test "list_participants/0 returns all participants" do
      participant = participant_fixture()
      assert Participants.list_participants() == [participant]
    end

    test "get_participant!/1 returns the participant with given id" do
      participant = participant_fixture()
      assert Participants.get_participant!(participant.id) == participant
    end

    test "create_participant/1 with valid data creates a participant" do
      valid_attrs = %{
        display_name: "some display_name",
        first_name: "some first_name",
        image_url: "some image_url",
        last_name: "some last_name",
        strava_auth: %{},
        strava_id: "some strava_id",
        strava_username: "some strava_username"
      }

      assert {:ok, %Participant{} = participant} = Participants.create_participant(valid_attrs)
      assert participant.display_name == "some display_name"
      assert participant.first_name == "some first_name"
      assert participant.image_url == "some image_url"
      assert participant.last_name == "some last_name"
      assert participant.strava_auth == %{}
      assert participant.strava_id == "some strava_id"
      assert participant.strava_username == "some strava_username"
    end

    test "create_participant/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Participants.create_participant(@invalid_attrs)
    end

    test "update_participant/2 with valid data updates the participant" do
      participant = participant_fixture()

      update_attrs = %{
        display_name: "some updated display_name",
        first_name: "some updated first_name",
        image_url: "some updated image_url",
        last_name: "some updated last_name",
        strava_auth: %{},
        strava_id: "some updated strava_id",
        strava_username: "some updated strava_username"
      }

      assert {:ok, %Participant{} = participant} =
               Participants.update_participant(participant, update_attrs)

      assert participant.display_name == "some updated display_name"
      assert participant.first_name == "some updated first_name"
      assert participant.image_url == "some updated image_url"
      assert participant.last_name == "some updated last_name"
      assert participant.strava_auth == %{}
      assert participant.strava_id == "some updated strava_id"
      assert participant.strava_username == "some updated strava_username"
    end

    test "update_participant/2 with invalid data returns error changeset" do
      participant = participant_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Participants.update_participant(participant, @invalid_attrs)

      assert participant == Participants.get_participant!(participant.id)
    end

    test "delete_participant/1 deletes the participant" do
      participant = participant_fixture()
      assert {:ok, %Participant{}} = Participants.delete_participant(participant)
      assert_raise Ecto.NoResultsError, fn -> Participants.get_participant!(participant.id) end
    end

    test "change_participant/1 returns a participant changeset" do
      participant = participant_fixture()
      assert %Ecto.Changeset{} = Participants.change_participant(participant)
    end
  end
end

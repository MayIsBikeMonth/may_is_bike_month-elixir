defmodule MayIsBikeMonth.ParticipantsTest do
  use MayIsBikeMonth.DataCase

  alias MayIsBikeMonth.{Participants, Participants.Participant}

  import MayIsBikeMonth.{ParticipantsFixtures, StravaTokensFixtures}

  describe "participants" do
    @invalid_attrs %{
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
      assert Participants.get_participant(participant.id) == participant
      assert Participants.get_participant_by_strava_id(participant.strava_id) == participant
      # It also works when passed an integer, since that's how they come in'
      assert Participants.get_participant_by_strava_id(2_430_215) == participant
    end

    test "list_strava_tokens/0 returns all strava_tokens" do
      strava_token = strava_token_fixture()
      assert strava_token.active == true
      assert Participants.list_strava_tokens() == [strava_token]
    end

    test "participant_from_strava_token_response/1 creates a strava_token" do
      {:ok, participant} =
        Participants.participant_from_strava_token_response(example_strava_token_response())

      assert Enum.count(Participants.list_participants()) == 1
      assert Enum.count(Participants.list_strava_tokens()) == 1

      strava_token = Participants.strava_token_for_participant(participant)
      assert strava_token.participant_id == participant.id
      assert strava_token.error_response == %{}
      assert strava_token.active == true

      # Create another token, test that the newest one is returned
      {:ok, _} =
        Participants.participant_from_strava_token_response(example_strava_token_response())

      assert Enum.count(Participants.list_participants()) == 1
      assert Enum.count(Participants.list_strava_tokens()) == 2
      strava_token2 = Participants.strava_token_for_participant(participant)
      assert strava_token2.participant_id == participant.id
      assert strava_token2.id > strava_token.id
    end

    test "participant_from_strava_token_response/1 creates a strava_token for an existing participant" do
      participant = participant_fixture()
      assert Participants.list_strava_tokens() == []
      strava_token_attrs = example_strava_token_response(strava_id: participant.strava_id)

      {:ok, participant} = Participants.participant_from_strava_token_response(strava_token_attrs)

      assert Enum.count(Participants.list_participants()) == 1

      assert Enum.count(Participants.list_strava_tokens()) == 1

      strava_token = Enum.at(Participants.list_strava_tokens(), 0)
      assert strava_token.participant_id == participant.id
      assert strava_token.active == true
    end

    test "active_strava_token_for_participant/1 gets strava_token" do
      participant = participant_fixture()
      strava_token = strava_token_fixture(%{participant_id: participant.id})
      assert strava_token.active == true
      assert Participants.active_strava_token_for_participant(participant) == strava_token
    end

    test "active_strava_token_for_participant/1 is nil if active strava_token is impossible" do
      participant = participant_fixture()
      assert Participants.active_strava_token_for_participant(participant) == nil
      error_response = %{body: %{"message" => "invalid_grant"}}

      {:ok, strava_token} =
        Participants.add_error_to_strava_token(
          strava_token_fixture(%{participant_id: participant.id}),
          error_response
        )

      assert strava_token.error_response == error_response
      assert strava_token.active == false
      assert Participants.active_strava_token_for_participant(participant) == nil
    end

    test "create_or_update_participant/1 with valid data creates a participant and updates the participant" do
      assert {:ok, %Participant{} = participant} =
               Participants.create_or_update_participant(%{
                 "id" => "999",
                 "username" => "some strava_username"
               })

      assert participant.display_name == "some strava_username"
      assert participant.strava_id == "999"

      assert {:ok, %Participant{} = participant_again} =
               Participants.create_or_update_participant(%{
                 "id" => "999",
                 "username" => "New strava_username",
                 "firstname" => "New",
                 "lastname" => "Name"
               })

      assert Enum.count(Participants.list_participants()) == 1
      assert participant_again.strava_username == "New strava_username"
      assert participant_again.first_name == "New"
      assert participant_again.last_name == "Name"

      assert {:ok, %Participant{} = _} =
               Participants.create_or_update_participant(%{
                 "id" => "998",
                 "username" => "new"
               })

      assert Enum.count(Participants.list_participants()) == 2
    end

    test "create_participant/1 with valid data creates a participant" do
      valid_attrs = %{
        first_name: "some first_name",
        image_url: "some image_url",
        last_name: "some last_name",
        strava_id: "some strava_id",
        strava_username: "some strava_username"
      }

      assert {:ok, %Participant{} = participant} = Participants.create_participant(valid_attrs)
      assert participant.display_name == "some strava_username"
      assert participant.first_name == "some first_name"
      assert participant.image_url == "some image_url"
      assert participant.last_name == "some last_name"
      assert participant.strava_id == "some strava_id"
      assert participant.strava_username == "some strava_username"
    end

    test "create_participant/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Participants.create_participant(@invalid_attrs)
    end

    test "create_partipant/1 with duplicate strava_id returns error changeset" do
      participant_attrs = %{
        display_name: "some display_name",
        first_name: "some first_name",
        image_url: "some image_url",
        last_name: "some last_name",
        strava_id: "123456",
        strava_username: "some strava_username"
      }

      Participants.create_participant(participant_attrs)
      duplicate_changeset = Participant.changeset(%Participant{}, participant_attrs)
      {:error, changeset} = Repo.insert(duplicate_changeset)

      {error, _} = changeset.errors[:strava_id]
      assert error == "has already been taken"
    end

    test "update_participant/2 with valid data updates the participant" do
      participant = participant_fixture()

      update_attrs = %{
        display_name: "some updated display_name",
        first_name: "some updated first_name",
        image_url: "some updated image_url",
        last_name: "some updated last_name",
        strava_id: "some updated strava_id",
        strava_username: "some updated strava_username"
      }

      assert {:ok, %Participant{} = participant} =
               Participants.update_participant(participant, update_attrs)

      assert participant.display_name == "some updated display_name"
      assert participant.first_name == "some updated first_name"
      assert participant.image_url == "some updated image_url"
      assert participant.last_name == "some updated last_name"
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

  describe "participants with vcr" do
    use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

    test "active_strava_token_for_participant/1 tries again if timed out" do
      setup_vcr()

      participant = participant_fixture()

      {:ok, new_token} =
        MayIsBikeMonth.Participants.create_strava_token(
          participant.id,
          "xxxxxxx",
          "yyyyyyy",
          DateTime.to_unix(DateTime.add(DateTime.utc_now(), 20721))
        )

      {:ok, strava_token} =
        Participants.add_error_to_strava_token(new_token, %{"body" => "timeout", "status" => 0})

      assert Enum.count(Participants.list_strava_tokens()) == 1
      assert Participants.refresh_access_token?(strava_token)

      use_cassette "active_strava_token_for_participant-success_with_error" do
        refreshed_token = Participants.active_strava_token_for_participant(participant)
        assert Enum.count(Participants.list_strava_tokens()) == 2
        assert refreshed_token.error_response == %{}
        assert refreshed_token.active == true
        assert refreshed_token.id != strava_token.id
        assert Participants.active_strava_token_for_participant(participant) == refreshed_token
        assert Enum.count(Participants.list_strava_tokens()) == 2
      end
    end

    test "refreshed_access_token/1 creates a new access token" do
      setup_vcr()

      use_cassette "refresh_access_token-success" do
        strava_token = strava_token_fixture(%{"expires_at" => token_expires_at(-1000)})

        assert strava_token.active == false
        assert Enum.count(Participants.list_strava_tokens()) == 1
        {:ok, refreshed_strava_token} = Participants.refreshed_access_token(strava_token)
        assert refreshed_strava_token.id != strava_token.id
        assert refreshed_strava_token.access_token == "xxxxxx"
        assert refreshed_strava_token.participant_id == strava_token.participant_id
        assert refreshed_strava_token.error_response == %{}
        assert Enum.count(Participants.list_strava_tokens()) == 2
      end
    end

    test "refreshed_access_token/1 adds an error to the access token" do
      setup_vcr()

      use_cassette "refresh_access_token-fail" do
        strava_token = strava_token_fixture(%{"expires_at" => token_expires_at(-1000)})

        assert strava_token.active == false
        assert Enum.count(Participants.list_strava_tokens()) == 1

        {:error, errored_strava_token} = Participants.refreshed_access_token(strava_token)
        assert errored_strava_token.id == strava_token.id
        assert errored_strava_token.participant_id == strava_token.participant_id
        assert errored_strava_token.active == false

        assert errored_strava_token.error_response == %{
                 status: 400,
                 body: %{
                   "errors" => [
                     %{
                       "code" => "invalid",
                       "field" => "refresh_token",
                       "resource" => "RefreshToken"
                     }
                   ],
                   "message" => "Bad Request"
                 }
               }

        assert Enum.count(Participants.list_strava_tokens()) == 1
      end
    end
  end
end

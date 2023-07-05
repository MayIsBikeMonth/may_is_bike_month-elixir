defmodule MayIsBikeMonth.CompetitionParticipantsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MayIsBikeMonth.CompetitionParticipants` context.
  """

  import MayIsBikeMonth.CompetitionsFixtures
  import MayIsBikeMonth.ParticipantsFixtures

  @doc """
  Generate a competition_participant.
  """
  def competition_participant_fixture(attrs \\ %{}) do
    participant_id = attrs[:participant_id] || participant_fixture() |> Map.get(:id)
    competition_id = attrs[:competition_id] || competition_fixture() |> Map.get(:id)

    {:ok, competition_participant} =
      attrs
      |> Enum.into(%{
        include_in_competition: true,
        participant_id: participant_id,
        competition_id: competition_id
      })
      |> MayIsBikeMonth.CompetitionParticipants.create_competition_participant()

    competition_participant
  end
end

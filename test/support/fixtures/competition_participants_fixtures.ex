defmodule MayIsBikeMonth.CompetitionParticipantsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MayIsBikeMonth.CompetitionParticipants` context.
  """

  @doc """
  Generate a competition_participant.
  """
  def competition_participant_fixture(attrs \\ %{}) do
    {:ok, competition_participant} =
      attrs
      |> Enum.into(%{
        include_in_competition: true,
        score: 120.5
      })
      |> MayIsBikeMonth.CompetitionParticipants.create_competition_participant()

    competition_participant
  end
end

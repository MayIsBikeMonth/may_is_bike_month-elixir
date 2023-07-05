defmodule MayIsBikeMonth.CompetitionActivitiesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MayIsBikeMonth.CompetitionActivities` context.
  """
  import MayIsBikeMonth.CompetitionParticipantsFixtures

  @doc """
  Generate a competition_activity.
  """
  def competition_activity_fixture(attrs \\ %{}) do
    competition_participant_id =
      attrs[:competition_participant_id] || competition_participant_fixture() |> Map.get(:id)

    {:ok, competition_activity} =
      attrs
      |> Enum.into(%{
        strava_data: %{},
        competition_participant_id: competition_participant_id
      })
      |> MayIsBikeMonth.CompetitionActivities.create_competition_activity()

    competition_activity
  end
end

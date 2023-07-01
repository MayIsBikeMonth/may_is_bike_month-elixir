defmodule MayIsBikeMonth.CompetitionActivitiesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MayIsBikeMonth.CompetitionActivities` context.
  """

  @doc """
  Generate a competition_activity.
  """
  def competition_activity_fixture(attrs \\ %{}) do
    {:ok, competition_activity} =
      attrs
      |> Enum.into(%{
        display_name: "some display_name",
        distance_meters: 42,
        duration_seconds: 42,
        elevation_meters: 42,
        end_date: ~D[2023-06-30],
        include_in_competition: true,
        start_at: ~U[2023-06-30 22:57:00Z],
        start_date: ~D[2023-06-30],
        strava_data: %{},
        strava_id: "some strava_id",
        timezone: "some timezone"
      })
      |> MayIsBikeMonth.CompetitionActivities.create_competition_activity()

    competition_activity
  end
end

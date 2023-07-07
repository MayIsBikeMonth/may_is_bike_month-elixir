defmodule MayIsBikeMonth.CompetitionActivitiesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MayIsBikeMonth.CompetitionActivities` context.
  """
  import MayIsBikeMonth.CompetitionParticipantsFixtures

  def load_strava_activity_data_fixture() do
    Path.expand("./strava_activity.json", __DIR__)
    |> File.read!()
    |> Jason.decode!()
  end

  @doc """
  Generate a competition_activity.
  """
  def competition_activity_fixture(attrs \\ %{}) do
    competition_participant = attrs[:competition_participant] || competition_participant_fixture()

    strava_data = attrs[:strava_data] || load_strava_activity_data_fixture()

    {:ok, competition_activity} =
      MayIsBikeMonth.CompetitionActivities.create_from_strava_data(
        competition_participant,
        strava_data
      )

    competition_activity
  end
end

defmodule MayIsBikeMonth.CompetitionActivitiesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MayIsBikeMonth.CompetitionActivities` context.
  """
  import MayIsBikeMonth.CompetitionParticipantsFixtures

  @doc """
  Generate a competition_activity
  """
  def competition_activity_fixture(attrs \\ %{}) do
    start_at = attrs[:start_at] || ~U[2023-05-14 19:08:57Z]
    timezone = attrs[:timezone] || "America/Los_Angeles"
    start_date = DateTime.to_date(MayIsBikeMonth.TimeFormatter.in_timezone(start_at, timezone))
    strava_data = attrs[:strava_data] || %{"type" => "Ride", "visibility" => "everyone"}

    competition_participant_id =
      attrs[:competition_participant_id] ||
        if attrs[:competition_participant] do
          attrs[:competition_participant].id
        else
          competition_participant_fixture().id
        end

    {:ok, competition_activity} =
      attrs
      |> Enum.into(%{
        competition_participant_id: competition_participant_id,
        strava_id: "9073105198",
        start_date: start_date,
        timezone: timezone,
        start_at: start_at,
        display_name: "Some bike ride",
        distance_meters: 100_069.9,
        elevation_meters: 696.9,
        moving_seconds: 10000,
        strava_data: strava_data
      })
      |> MayIsBikeMonth.CompetitionActivities.create_competition_activity()

    competition_activity
  end

  def load_strava_activity_data_fixture() do
    Path.expand("./strava_activity.json", __DIR__)
    |> File.read!()
    |> Jason.decode!()
  end

  @doc """
  Generate a competition_activity from the strava_activity.json fixture.
  """
  def competition_activity_fixture_from_strava_data(attrs \\ %{}) do
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

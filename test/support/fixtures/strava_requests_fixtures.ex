defmodule MayIsBikeMonth.StravaRequestsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MayIsBikeMonth.StravaRequests` context.
  """
  import MayIsBikeMonth.ParticipantsFixtures

  @doc """
  Generate a strava_request.
  """
  def strava_request_fixture(attrs \\ %{}) do
    participant_id =
      if attrs[:participant_id] do
        attrs[:participant_id]
      else
        participant_fixture(strava_id: attrs[:strava_id] || "2430215")
        |> Map.get(:id)
      end

    {:ok, strava_request} =
      attrs
      |> Enum.into(%{
        error_response: %{},
        options: %{},
        status: 200,
        kind: :get_activities,
        participant_id: participant_id
      })
      |> MayIsBikeMonth.StravaRequests.create_strava_request()

    strava_request
  end
end

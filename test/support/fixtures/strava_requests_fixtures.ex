defmodule MayIsBikeMonth.StravaRequestsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MayIsBikeMonth.StravaRequests` context.
  """

  @doc """
  Generate a strava_request.
  """
  def strava_request_fixture(attrs \\ %{}) do
    {:ok, strava_request} =
      attrs
      |> Enum.into(%{
        error_response: %{},
        options: %{},
        status: 42,
        type: 42
      })
      |> MayIsBikeMonth.StravaRequests.create_strava_request()

    strava_request
  end
end

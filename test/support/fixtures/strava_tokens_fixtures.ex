defmodule MayIsBikeMonth.StravaTokensFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MayIsBikeMonth.CompetitionParticipants` context.
  """
  import MayIsBikeMonth.ParticipantsFixtures

  @default_strava_id "2430215"

  def token_expires_at(expires_in) do
    DateTime.utc_now()
    |> DateTime.add(expires_in, :second)
    |> DateTime.to_unix()
  end

  def example_strava_token_response(attrs \\ %{}) do
    strava_id = attrs[:strava_id] || @default_strava_id

    %{
      "token_type" => "Bearer",
      "expires_at" => token_expires_at(21600),
      "expires_in" => 21600,
      "refresh_token" => "xxxx-refresh-token",
      "access_token" => "yyyy-access-token",
      "athlete" => %{
        "id" => strava_id,
        "username" => "sethherr",
        "resource_state" => 2,
        "firstname" => "seth",
        "lastname" => "herr",
        "bio" => "",
        "city" => "Oakland",
        "state" => "California",
        "country" => "United States",
        "sex" => "M",
        "premium" => true,
        "summit" => true,
        "created_at" => "2013-06-26T20:41:15Z",
        "updated_at" => "2023-06-25T15:14:43Z",
        "badge_type_id" => 1,
        "weight" => 72.5748,
        "profile_medium" =>
          "https://dgalywyr863hv.cloudfront.net/pictures/athletes/2430215/2807433/6/medium.jpg",
        "profile" =>
          "https://dgalywyr863hv.cloudfront.net/pictures/athletes/2430215/2807433/6/large.jpg",
        "friend" => nil,
        "follower" => nil
      }
    }
  end

  @doc """
  Generate a competition_participant.
  """
  def strava_token_fixture(attrs \\ %{}) do
    participant_id =
      if attrs[:participant_id] do
        attrs[:participant_id]
      else
        participant_fixture(strava_id: attrs[:strava_id] || @default_strava_id)
        |> Map.get(:id)
      end

    %{
      "access_token" => access,
      "refresh_token" => refresh,
      "expires_at" => expires_at,
      "athlete" => meta,
      "token_type" => "Bearer",
      "expires_in" => _
    } = example_strava_token_response(strava_id: attrs[:strava_id] || @default_strava_id)

    {:ok, strava_token} =
      MayIsBikeMonth.Participants.create_strava_token(
        participant_id,
        access,
        refresh,
        expires_at,
        meta
      )

    strava_token
  end
end

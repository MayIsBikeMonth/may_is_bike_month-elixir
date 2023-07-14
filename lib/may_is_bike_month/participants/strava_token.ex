defmodule MayIsBikeMonth.Participants.StravaToken do
  use Ecto.Schema
  import Ecto.Changeset

  schema "strava_tokens" do
    field :access_token, :string
    field :expires_at, :utc_datetime
    field :refresh_token, :string
    field :strava_meta, :map, default: %{}
    field :participant_id, :id

    timestamps()
  end

  @doc false
  def changeset(strava_token, attrs) do
    strava_token
    |> cast(attrs, [:access_token, :refresh_token, :expires_at])
    |> validate_required([:access_token, :refresh_token, :expires_at])
  end
end

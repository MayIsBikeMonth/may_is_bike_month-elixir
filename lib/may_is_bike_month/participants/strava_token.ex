defmodule MayIsBikeMonth.Participants.StravaToken do
  use Ecto.Schema
  import Ecto.Changeset

  schema "strava_tokens" do
    field :access_token, :string
    field :expires_at, :utc_datetime
    field :active, :boolean, default: false, virtual: true
    field :refresh_token, :string
    field :strava_meta, :map, default: %{}
    field :error_response, :map, default: %{}
    belongs_to :participant, MayIsBikeMonth.Participants.Participant

    timestamps()
  end

  @doc false
  def changeset(strava_token, attrs) do
    strava_token
    |> cast(attrs, [
      :access_token,
      :refresh_token,
      :expires_at,
      :strava_meta,
      :participant_id,
      :error_response
    ])
    |> validate_required([:access_token, :expires_at, :participant_id])
    |> with_active()
  end

  def with_active(changeset) do
    expires_at = get_field(changeset, :expires_at)

    put_change(changeset, :active, MayIsBikeMonth.Participants.strava_token_active?(expires_at))
  end
end

defmodule MayIsBikeMonth.CompetitionActivities.CompetitionActivity do
  use Ecto.Schema
  import Ecto.Changeset

  schema "competition_activities" do
    field :display_name, :string
    field :distance_meters, :integer
    field :duration_seconds, :integer
    field :elevation_meters, :integer
    field :end_date, :date
    field :include_in_competition, :boolean, default: false
    field :start_at, :utc_datetime
    field :start_date, :date
    field :strava_data, :map
    field :strava_id, :string
    field :timezone, :string
    field :competition_participant_id, :id

    timestamps()
  end

  @doc false
  def changeset(competition_activity, attrs) do
    competition_activity
    |> cast(attrs, [:display_name, :duration_seconds, :start_at, :timezone, :start_date, :end_date, :strava_id, :strava_data, :include_in_competition, :distance_meters, :elevation_meters])
    |> validate_required([:display_name, :duration_seconds, :start_at, :timezone, :start_date, :end_date, :strava_id, :strava_data, :include_in_competition, :distance_meters, :elevation_meters])
  end
end

defmodule MayIsBikeMonth.CompetitionActivities.CompetitionActivity do
  use Ecto.Schema
  import Ecto.Changeset

  schema "competition_activities" do
    field :display_name, :string
    field :distance_meters, :float
    field :moving_seconds, :integer
    field :elevation_meters, :float
    field :end_date, :date
    field :include_in_competition, :boolean, default: false
    field :start_at, :utc_datetime
    field :start_date, :date
    field :strava_data, :map
    field :strava_id, :string
    field :timezone, :string

    belongs_to :competition_participant,
               MayIsBikeMonth.CompetitionParticipants.CompetitionParticipant

    timestamps()
  end

  @doc false
  def changeset(competition_activity, attrs) do
    competition_activity
    |> cast(attrs, [
      :display_name,
      :moving_seconds,
      :start_at,
      :timezone,
      :start_date,
      :end_date,
      :strava_id,
      :strava_data,
      :include_in_competition,
      :distance_meters,
      :elevation_meters,
      :competition_participant_id
    ])
    |> validate_required([:competition_participant_id, :strava_id, :strava_data])
    |> unique_constraint(:competition_participant_id_strava_id,
      name: "competition_activities_competition_participant_id_strava_id_ind"
    )
  end
end

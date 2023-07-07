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
    |> with_end_date()
  end

  defp with_end_date(changeset) do
    start_at = get_field(changeset, :start_at)
    moving_seconds = get_field(changeset, :moving_seconds)
    timezone = get_field(changeset, :timezone)

    if start_at && moving_seconds && timezone do
      dates =
        MayIsBikeMonth.CompetitionActivities.activity_dates(start_at, timezone, moving_seconds)

      put_change(changeset, :end_date, List.last(dates))
    else
      changeset
    end
  end
end

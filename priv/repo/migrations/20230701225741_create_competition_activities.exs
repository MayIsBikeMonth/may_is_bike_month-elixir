defmodule MayIsBikeMonth.Repo.Migrations.CreateCompetitionActivities do
  use Ecto.Migration

  def change do
    create table(:competition_activities) do
      add :display_name, :string
      add :duration_seconds, :integer
      add :start_at, :utc_datetime
      add :timezone, :string
      add :start_date, :date
      add :end_date, :date
      add :strava_id, :string
      add :strava_data, :map
      add :include_in_competition, :boolean, default: false, null: false
      add :distance_meters, :integer
      add :elevation_meters, :integer
      add :competition_participant_id, references(:competition_participants, on_delete: :nothing)

      timestamps()
    end

    create index(:competition_activities, [:competition_participant_id])
  end
end

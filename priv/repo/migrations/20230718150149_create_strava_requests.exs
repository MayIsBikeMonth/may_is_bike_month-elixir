defmodule MayIsBikeMonth.Repo.Migrations.CreateStravaRequests do
  use Ecto.Migration

  def change do
    create table(:strava_requests) do
      add :type, :integer
      add :status, :integer
      add :error_response, :map
      add :options, :map
      add :participant_id, references(:participants, on_delete: :nothing)

      timestamps()
    end

    create index(:strava_requests, [:participant_id])
  end
end

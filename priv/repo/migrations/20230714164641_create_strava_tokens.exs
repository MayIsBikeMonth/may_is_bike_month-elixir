defmodule MayIsBikeMonth.Repo.Migrations.CreateStravaTokens do
  use Ecto.Migration

  def change do
    create table(:strava_tokens) do
      add :access_token, :string
      add :refresh_token, :string
      add :expires_at, :utc_datetime
      add :strava_meta, :map
      add :error_response, :map
      add :participant_id, references(:participants, on_delete: :nothing)

      timestamps()
    end

    alter table(:participants) do
      remove :strava_auth, :map
    end

    create index(:strava_tokens, [:participant_id])
  end
end

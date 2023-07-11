defmodule MayIsBikeMonth.Repo.Migrations.CreateParticipants do
  use Ecto.Migration

  def change do
    create table(:participants) do
      add :display_name, :string
      add :first_name, :string
      add :last_name, :string
      add :strava_username, :string
      add :strava_id, :string
      add :image_url, :string
      add :strava_auth, :map

      timestamps()
    end

    create unique_index(:participants, [:strava_id])
  end
end

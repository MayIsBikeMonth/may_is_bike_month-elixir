defmodule MayIsBikeMonth.Repo.Migrations.CreateCompetitions do
  use Ecto.Migration

  def change do
    create table(:competitions) do
      add :display_name, :string
      add :start_date, :date
      add :end_date, :date
      add :slug, :string

      timestamps()
    end
  end
end

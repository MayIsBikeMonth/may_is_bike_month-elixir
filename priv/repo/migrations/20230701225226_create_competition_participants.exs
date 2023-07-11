defmodule MayIsBikeMonth.Repo.Migrations.CreateCompetitionParticipants do
  use Ecto.Migration

  def change do
    create table(:competition_participants) do
      add(:score, :float)
      add(:include_in_competition, :boolean, default: false, null: false)
      add(:participant_id, references(:participants, on_delete: :nothing))
      add(:competition_id, references(:competitions, on_delete: :nothing))
      add(:score_data, :map, default: %{}, null: false)

      timestamps()
    end

    create unique_index(:competition_participants, [:participant_id, :competition_id])
    create(index(:competition_participants, [:participant_id]))
    create(index(:competition_participants, [:competition_id]))
  end
end

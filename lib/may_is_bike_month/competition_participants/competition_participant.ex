defmodule MayIsBikeMonth.CompetitionParticipants.CompetitionParticipant do
  use Ecto.Schema
  import Ecto.Changeset

  schema "competition_participants" do
    field :include_in_competition, :boolean, default: false
    field :score, :float, default: 0.0
    belongs_to :participant, MayIsBikeMonth.Participants.Participant
    belongs_to :competition, MayIsBikeMonth.Competitions.Competition
    field :valid_activity_types, :map, virtual: true

    timestamps()
  end

  @doc false
  def changeset(competition_participant, attrs) do
    competition_participant
    |> cast(attrs, [:score, :include_in_competition, :participant_id, :competition_id])
    |> validate_required([:competition_id, :participant_id])
  end
end

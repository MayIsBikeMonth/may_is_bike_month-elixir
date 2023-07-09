defmodule MayIsBikeMonth.CompetitionParticipants.CompetitionParticipant do
  use Ecto.Schema
  import Ecto.Changeset

  schema "competition_participants" do
    field :include_in_competition, :boolean, default: false
    field :score, :float, default: 0.0
    belongs_to :participant, MayIsBikeMonth.Participants.Participant
    belongs_to :competition, MayIsBikeMonth.Competitions.Competition
    field :score_data, :map, default: %{}
    field :included_activity_types, :map, virtual: true

    timestamps()
  end

  @doc false
  def changeset(competition_participant, attrs) do
    competition_participant
    |> cast(attrs, [
      :score,
      :include_in_competition,
      :participant_id,
      :competition_id,
      :score_data
    ])
    |> validate_required([:competition_id, :participant_id])
    |> unique_constraint(:participant_id_competition_id)
    |> with_score()
  end

  defp with_score(changeset) do
    score_data = get_field(changeset, :score_data)
    score = (score_data && score_data["score"]) || 0.0
    put_change(changeset, :score, score)
  end
end

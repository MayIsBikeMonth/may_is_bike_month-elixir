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
    |> with_score_data_and_score()
  end

  defp with_score_data_and_score(changeset) do
    score_data_field = get_field(changeset, :score_data) || %{}

    score_data =
      if score_data_field == %{} do
        MayIsBikeMonth.CompetitionParticipants.empty_score_data(
          get_field(changeset, :competition_id)
        )
      else
        score_data_field
      end

    put_change(changeset, :score_data, score_data)
    |> with_score(score_data)
  end

  defp with_score(changeset, score_data) do
    put_change(changeset, :score, score_data["score"])
  end
end

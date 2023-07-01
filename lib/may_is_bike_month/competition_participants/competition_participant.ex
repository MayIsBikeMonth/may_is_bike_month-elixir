defmodule MayIsBikeMonth.CompetitionParticipants.CompetitionParticipant do
  use Ecto.Schema
  import Ecto.Changeset

  schema "competition_participants" do
    field :include_in_competition, :boolean, default: false
    field :score, :float
    field :athlete_id, :id
    field :competition_id, :id

    timestamps()
  end

  @doc false
  def changeset(competition_participant, attrs) do
    competition_participant
    |> cast(attrs, [:score, :include_in_competition])
    |> validate_required([:score, :include_in_competition])
  end
end
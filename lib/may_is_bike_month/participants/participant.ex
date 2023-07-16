defmodule MayIsBikeMonth.Participants.Participant do
  use Ecto.Schema
  import Ecto.Changeset

  schema "participants" do
    field :display_name, :string
    field :first_name, :string
    field :image_url, :string
    field :last_name, :string
    field :strava_id, :string
    field :strava_username, :string

    has_many :competition_participants,
             MayIsBikeMonth.CompetitionParticipants.CompetitionParticipant

    timestamps()
  end

  @doc false
  def changeset(participant, attrs) do
    participant
    |> cast(attrs, [
      :display_name,
      :first_name,
      :last_name,
      :strava_username,
      :strava_id,
      :image_url
    ])
    |> validate_required([
      :strava_username,
      :strava_id
    ])
    |> with_display_name()
    |> unique_constraint(:strava_id)
  end

  defp with_display_name(changeset) do
    display_name = get_field(changeset, :display_name)
    strava_username = get_field(changeset, :strava_username)
    put_change(changeset, :display_name, display_name || strava_username)
  end
end

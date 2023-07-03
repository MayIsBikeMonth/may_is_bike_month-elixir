defmodule MayIsBikeMonth.Participants.Participant do
  use Ecto.Schema
  import Ecto.Changeset

  schema "participants" do
    field :display_name, :string
    field :first_name, :string
    field :image_url, :string
    field :last_name, :string
    field :strava_auth, :map
    field :strava_id, :string
    field :strava_username, :string

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
      :image_url,
      :strava_auth
    ])
    |> validate_required([
      :display_name,
      :first_name,
      :last_name,
      :strava_username,
      :strava_id,
      :image_url,
      :strava_auth
    ])
  end
end

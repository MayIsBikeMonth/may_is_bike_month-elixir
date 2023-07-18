defmodule MayIsBikeMonth.StravaRequests.StravaRequest do
  use Ecto.Schema
  import Ecto.Changeset

  schema "strava_requests" do
    field :error_response, :map, default: %{}
    field :options, :map, default: %{}
    field :status, :integer
    field :type, Ecto.Enum, values: [get_activities: 0]
    belongs_to :participant, MayIsBikeMonth.Participants.Participant

    timestamps()
  end

  @doc false
  def changeset(strava_request, attrs) do
    strava_request
    |> cast(attrs, [:type, :status, :error_response, :options, :participant_id])
    |> validate_required([:type, :status])
  end
end

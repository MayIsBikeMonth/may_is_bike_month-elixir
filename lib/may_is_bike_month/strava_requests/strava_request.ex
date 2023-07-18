defmodule MayIsBikeMonth.StravaRequests.StravaRequest do
  use Ecto.Schema
  import Ecto.Changeset

  schema "strava_requests" do
    field :error_response, :map
    field :options, :map
    field :status, :integer
    field :type, :integer
    field :participant_id, :id

    timestamps()
  end

  @doc false
  def changeset(strava_request, attrs) do
    strava_request
    |> cast(attrs, [:type, :status, :error_response, :options])
    |> validate_required([:type, :status, :error_response, :options])
  end
end

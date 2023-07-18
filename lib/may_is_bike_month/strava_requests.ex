defmodule MayIsBikeMonth.StravaRequests do
  @moduledoc """
  The StravaRequests context.
  """

  import Ecto.Query, warn: false
  alias MayIsBikeMonth.Repo

  alias MayIsBikeMonth.{StravaRequests.StravaRequest, Strava, Participants}

  @doc """
  Returns the list of strava_requests.

  ## Examples

      iex> list_strava_requests()
      [%StravaRequest{}, ...]

  """
  def list_strava_requests do
    Repo.all(StravaRequest)
  end

  def list_strava_requests_load_participant do
    from(StravaRequest, order_by: [desc: :id])
    |> Repo.all()
    |> Repo.preload(:participant)
  end

  @doc """
  Gets a single strava_request.

  Raises `Ecto.NoResultsError` if the Strava request does not exist.

  ## Examples

      iex> get_strava_request!(123)
      %StravaRequest{}

      iex> get_strava_request!(456)
      ** (Ecto.NoResultsError)

  """
  def get_strava_request!(id), do: Repo.get!(StravaRequest, id)

  def parameters_for_activities_for_competition(competition) do
    before =
      competition.end_date
      |> DateTime.new!(~T[00:00:00.000], "Etc/UTC")
      |> DateTime.add(2, :day)

    afters =
      competition.start_date
      |> DateTime.new!(~T[00:00:00.000], "Etc/UTC")
      |> DateTime.add(-2, :day)

    %{
      "before" => DateTime.to_unix(before),
      "after" => DateTime.to_unix(afters),
      "per_page" => "50"
    }
  end

  @doc """
  Creates a strava_request for a participant in a competition

  Returns the strava activities
  """
  def request_participant_activities_for_competition(participant, competition, parameters \\ %{}) do
    request_parameters =
      parameters_for_activities_for_competition(competition)
      |> Map.merge(parameters)

    strava_token = Participants.active_strava_token_for_participant(participant)

    if strava_token do
      attrs = %{
        parameters: request_parameters,
        status: 200,
        kind: :get_activities,
        participant_id: participant.id
      }

      case Strava.get_activities(strava_token.access_token, request_parameters) do
        {:ok, activities} ->
          create_strava_request(attrs)
          {:ok, activities}

        {:error, error_response} ->
          create_strava_request(
            Map.merge(attrs, %{status: error_response.status, error_response: error_response.body})
          )

          {:error, error_response}
      end
    end
  end

  @doc """
  Creates a strava_request.
  """
  def create_strava_request(attrs \\ %{}) do
    %StravaRequest{}
    |> StravaRequest.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a strava_request.

  ## Examples

      iex> delete_strava_request(strava_request)
      {:ok, %StravaRequest{}}

      iex> delete_strava_request(strava_request)
      {:error, %Ecto.Changeset{}}

  """
  def delete_strava_request(%StravaRequest{} = strava_request) do
    Repo.delete(strava_request)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking strava_request changes.

  ## Examples

      iex> change_strava_request(strava_request)
      %Ecto.Changeset{data: %StravaRequest{}}

  """
  def change_strava_request(%StravaRequest{} = strava_request, attrs \\ %{}) do
    StravaRequest.changeset(strava_request, attrs)
  end
end
defmodule MayIsBikeMonth.StravaRequests do
  @moduledoc """
  The StravaRequests context.
  """

  import Ecto.Query, warn: false
  alias MayIsBikeMonth.Repo

  alias MayIsBikeMonth.{
    Competitions,
    CompetitionActivities,
    CompetitionParticipants,
    Participants,
    StravaRequests.StravaRequest,
    Strava
  }

  @update_duration 60

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

  def update_due?() do
    most_recent_update = most_recent_update()

    if most_recent_update do
      update_compare =
        most_recent_update
        |> DateTime.compare(DateTime.add(DateTime.utc_now(), -@update_duration))

      update_compare != :gt
    else
      false
    end
  end

  def most_recent_update() do
    most_recent =
      from(sr in StravaRequest,
        order_by: [desc: sr.id]
      )
      |> first()
      |> Repo.one()

    most_recent && most_recent.inserted_at |> DateTime.from_naive!("Etc/UTC")
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

    if strava_token && strava_token.active do
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
  Creates the strava activities. This is the money shot
  """
  def update_competition_participant_activities(competition_participant) do
    competition = Competitions.get_competition!(competition_participant.competition_id)

    with {:ok, activites} <-
           request_participant_activities_for_competition(
             competition_participant.participant,
             competition
           ),
         _created_competition_activities <-
           Enum.map(activites, fn actv ->
             CompetitionActivities.create_or_update_from_strava_data(
               competition_participant,
               actv
             )
           end) do
      CompetitionParticipants.update_calculated_score(competition_participant)
    else
      result -> result
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
end

defmodule MayIsBikeMonth.StravaRequests do
  @moduledoc """
  The StravaRequests context.
  """

  import Ecto.Query, warn: false
  alias MayIsBikeMonth.Repo

  alias MayIsBikeMonth.StravaRequests.StravaRequest

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

  @doc """
  Creates a strava_request.

  ## Examples

      iex> create_strava_request(%{field: value})
      {:ok, %StravaRequest{}}

      iex> create_strava_request(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_strava_request(attrs \\ %{}) do
    %StravaRequest{}
    |> StravaRequest.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a strava_request.

  ## Examples

      iex> update_strava_request(strava_request, %{field: new_value})
      {:ok, %StravaRequest{}}

      iex> update_strava_request(strava_request, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_strava_request(%StravaRequest{} = strava_request, attrs) do
    strava_request
    |> StravaRequest.changeset(attrs)
    |> Repo.update()
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

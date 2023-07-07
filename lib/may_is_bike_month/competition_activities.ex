defmodule MayIsBikeMonth.CompetitionActivities do
  @moduledoc """
  The CompetitionActivities context.
  """

  @ignored_strava_keys [
    "map",
    "segment_efforts",
    "splits_metric",
    "splits_standard",
    "laps",
    "stats_visibility"
  ]

  @included_strava_visibilities ["everyone", "followers_only"]

  import Ecto.Query, warn: false
  alias MayIsBikeMonth.Repo

  alias MayIsBikeMonth.CompetitionActivities.CompetitionActivity

  @doc """
  Returns the list of competition_activities.

  ## Examples

      iex> list_competition_activities()
      [%CompetitionActivity{}, ...]

  """
  def list_competition_activities do
    Repo.all(CompetitionActivity)
  end

  @doc """
  Gets a single competition_activity.

  Raises `Ecto.NoResultsError` if the Competition activity does not exist.

  ## Examples

      iex> get_competition_activity!(123)
      %CompetitionActivity{}

      iex> get_competition_activity!(456)
      ** (Ecto.NoResultsError)

  """
  def get_competition_activity!(id), do: Repo.get!(CompetitionActivity, id)

  def strava_attrs_from_data(strava_data) do
    start_at = Timex.parse!(strava_data["start_date"], "{RFC3339z}")
    start_date = DateTime.to_date(Timex.parse!(strava_data["start_date_local"], "{RFC3339z}"))

    timezone =
      Regex.replace(~r/\([^\)]*\)/, strava_data["timezone"], "")
      |> String.trim()

    %{
      strava_id: "#{strava_data["id"]}",
      start_date: start_date,
      end_date: nil,
      timezone: timezone,
      start_at: start_at,
      display_name: strava_data["name"],
      distance_meters: strava_data["distance"],
      elevation_meters: strava_data["total_elevation_gain"],
      moving_seconds: strava_data["moving_time"]
    }
  end

  def calculated_include_in_competition?(competition_participant, strava_data) do
    included_activity_type =
      MayIsBikeMonth.CompetitionParticipants.included_activity_type?(
        competition_participant,
        strava_data["type"]
      )

    included_distance =
      MayIsBikeMonth.CompetitionParticipants.included_distance?(
        competition_participant,
        strava_data["distance"]
      )

    visible = Enum.member?(@included_strava_visibilities, strava_data["visibility"])

    competition_participant.include_in_competition && visible && included_activity_type &&
      included_distance
  end

  def create_from_strava_data(competition_participant, strava_data) do
    strava_attrs = strava_attrs_from_data(strava_data)
    stored_strava_data = Map.drop(strava_data, @ignored_strava_keys)

    create_competition_activity(
      Map.merge(strava_attrs, %{
        competition_participant_id: competition_participant.id,
        strava_data: stored_strava_data,
        include_in_competition:
          calculated_include_in_competition?(competition_participant, strava_data)
      })
    )
  end

  @doc """
  Creates a competition_activity.

  ## Examples

      iex> create_competition_activity(%{field: value})
      {:ok, %CompetitionActivity{}}

      iex> create_competition_activity(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_competition_activity(attrs \\ %{}) do
    %CompetitionActivity{}
    |> CompetitionActivity.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a competition_activity.

  ## Examples

      iex> update_competition_activity(competition_activity, %{field: new_value})
      {:ok, %CompetitionActivity{}}

      iex> update_competition_activity(competition_activity, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_competition_activity(%CompetitionActivity{} = competition_activity, attrs) do
    competition_activity
    |> CompetitionActivity.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a competition_activity.

  ## Examples

      iex> delete_competition_activity(competition_activity)
      {:ok, %CompetitionActivity{}}

      iex> delete_competition_activity(competition_activity)
      {:error, %Ecto.Changeset{}}

  """
  def delete_competition_activity(%CompetitionActivity{} = competition_activity) do
    Repo.delete(competition_activity)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking competition_activity changes.

  ## Examples

      iex> change_competition_activity(competition_activity)
      %Ecto.Changeset{data: %CompetitionActivity{}}

  """
  def change_competition_activity(%CompetitionActivity{} = competition_activity, attrs \\ %{}) do
    CompetitionActivity.changeset(competition_activity, attrs)
  end
end

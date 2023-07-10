defmodule MayIsBikeMonth.CompetitionParticipants do
  @moduledoc """
  The CompetitionParticipants context.
  """

  @default_included_activity_types ["Ride", "Velomobile", "Handcycle"]
  # 2 miles
  @minimum_distance 3219

  import Ecto.Query, warn: false
  alias MayIsBikeMonth.Repo

  alias MayIsBikeMonth.CompetitionParticipants.CompetitionParticipant

  @doc """
  Returns the list of competition_participants.

  ## Examples

      iex> list_competition_participants()
      [%CompetitionParticipant{}, ...]

  """
  def list_competition_participants do
    from(CompetitionParticipant)
    |> order_by([cp], desc: cp.score)
    |> Repo.all()
    |> Repo.preload(:participant)
  end

  def for_competition(competition) do
    from(cp in CompetitionParticipant,
      where: cp.competition_id == ^competition.id,
      where: cp.include_in_competition == true,
      order_by: [desc: cp.score]
    )
    |> Repo.all()
    |> Repo.preload(:participant)
  end

  @doc """
  Gets a single competition_participant.

  Raises `Ecto.NoResultsError` if the Competition participant does not exist.

  ## Examples

      iex> get_competition_participant!(123)
      %CompetitionParticipant{}

      iex> get_competition_participant!(456)
      ** (Ecto.NoResultsError)

  """
  def get_competition_participant!(id) do
    Repo.get!(CompetitionParticipant, id)
    |> Repo.preload(:participant)
  end

  @doc """
  Creates a competition_participant.

  ## Examples

      iex> create_competition_participant(%{field: value})
      {:ok, %CompetitionParticipant{}}

      iex> create_competition_participant(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_competition_participant(attrs \\ %{}) do
    %CompetitionParticipant{}
    |> CompetitionParticipant.changeset(attrs)
    |> Repo.insert()
    |> with_participant()
  end

  defp with_participant({:error, changeset}), do: {:error, changeset}

  defp with_participant({:ok, competition_participant}) do
    {:ok, Repo.preload(competition_participant, :participant)}
  end

  @doc """
  Updates a competition_participant.

  ## Examples

      iex> update_competition_participant(competition_participant, %{field: new_value})
      {:ok, %CompetitionParticipant{}}

      iex> update_competition_participant(competition_participant, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_competition_participant(%CompetitionParticipant{} = competition_participant, attrs) do
    competition_participant
    |> CompetitionParticipant.changeset(attrs)
    |> Repo.update()
    |> with_participant()
  end

  @doc """
  Deletes a competition_participant.

  ## Examples

      iex> delete_competition_participant(competition_participant)
      {:ok, %CompetitionParticipant{}}

      iex> delete_competition_participant(competition_participant)
      {:error, %Ecto.Changeset{}}

  """
  def delete_competition_participant(%CompetitionParticipant{} = competition_participant) do
    Repo.delete(competition_participant)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking competition_participant changes.

  ## Examples

      iex> change_competition_participant(competition_participant)
      %Ecto.Changeset{data: %CompetitionParticipant{}}

  """
  def change_competition_participant(
        %CompetitionParticipant{} = competition_participant,
        attrs \\ %{}
      ) do
    CompetitionParticipant.changeset(competition_participant, attrs)
  end

  def included_activity_types(%CompetitionParticipant{} = competition_participant) do
    competition_participant.included_activity_types || @default_included_activity_types
  end

  def included_activity_type?(%CompetitionParticipant{} = competition_participant, activity_type) do
    Enum.member?(
      included_activity_types(competition_participant),
      activity_type
    )
  end

  def included_distance?(%CompetitionParticipant{} = _competition_participant, distance_meters) do
    distance_meters && distance_meters >= @minimum_distance
  end

  # Convenience, update all the scores
  def update_calculated_scores() do
    competition_participants = list_competition_participants()

    Enum.each(competition_participants, fn competition_participant ->
      update_calculated_score(competition_participant)
    end)
  end

  def update_calculated_score(%CompetitionParticipant{} = competition_participant) do
    update_competition_participant(competition_participant, %{
      score_data: calculate_scoring_data(competition_participant)
    })
  end

  def calculate_scoring_data(%CompetitionParticipant{} = competition_participant) do
    competition =
      MayIsBikeMonth.Competitions.get_competition!(competition_participant.competition_id)

    calculate_scoring_data(competition_participant, competition)
  end

  defp calculate_scoring_data(%CompetitionParticipant{} = competition_participant, competition) do
    calculate_scoring_periods_with_activities(competition_participant, competition)
    |> scoring_periods_with_scoring_data()
  end

  # TODO: combine with scoring_data_for_period
  defp scoring_periods_with_scoring_data(scoring_periods_with_activities) do
    score_data = dates_distance_elevation(scoring_periods_with_activities)

    Map.merge(score_data, %{
      "periods" => scoring_periods_with_activities,
      "score" => calculate_score(score_data["dates"], score_data["distance_meters"])
    })
  end

  # TODO: should be private except tests
  def calculate_scoring_periods_with_activities(
        %CompetitionParticipant{} = competition_participant,
        competition
      ) do
    competition.periods
    |> Enum.map(fn period ->
      period_activities_data(competition_participant, period)
      |> scoring_data_for_period()
    end)
  end

  def calculate_score(dates, distance_meters) do
    if length(dates) == 0 do
      0
    else
      1 - 1 / distance_meters + length(dates)
    end
  end

  # TODO: should be private except tests
  def period_activities_data(
        %CompetitionParticipant{} = competition_participant,
        %{start_date: start_date, end_date: end_date}
      ) do
    period_dates =
      Date.range(start_date, end_date)
      |> MapSet.new()

    MayIsBikeMonth.CompetitionActivities.list_competition_activities(%{
      competition_participant_id: competition_participant.id,
      include_in_competition: true,
      start_date: start_date,
      end_date: end_date,
      # Because, when rendering in the table, we want the oldest activity at the top
      order_direction: :asc
    })
    |> Enum.map(fn actv ->
      MayIsBikeMonth.CompetitionActivities.period_score_data(actv, start_date, period_dates)
    end)
  end

  # TODO: should be private except tests
  def scoring_data_for_period(activities_data) do
    Map.merge(dates_distance_elevation(activities_data), %{"activities" => activities_data})
  end

  defp dates_distance_elevation(activities_data) do
    %{
      "dates" =>
        Enum.reduce(activities_data, MapSet.new([]), fn a_data, acc ->
          MapSet.union(acc, MapSet.new(a_data["dates"]))
        end)
        |> MapSet.to_list(),
      "distance_meters" =>
        Enum.reduce(activities_data, 0, fn a_data, acc -> a_data["distance_meters"] + acc end),
      "elevation_meters" =>
        Enum.reduce(activities_data, 0, fn a_data, acc -> a_data["elevation_meters"] + acc end)
    }
  end
end

defmodule MayIsBikeMonth.CompetitionParticipants do
  @moduledoc """
  The CompetitionParticipants context.
  """

  @default_included_activity_types ["Ride", "Velomobile", "Handcycle"]
  # 2 miles
  @minimum_distance 3219

  import Ecto.Query, warn: false
  alias MayIsBikeMonth.Repo

  alias MayIsBikeMonth.{
    Competitions,
    CompetitionParticipants.CompetitionParticipant
  }

  def subscribe do
    Phoenix.PubSub.subscribe(MayIsBikeMonth.PubSub, "competition_participants")
  end

  def broadcast({:ok, competition_participant}, tag) do
    Phoenix.PubSub.broadcast(
      MayIsBikeMonth.PubSub,
      "competition_participants",
      {tag, competition_participant}
    )

    {:ok, competition_participant}
  end

  def broadcast({:error, _competition_participant} = error, _tag), do: error

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
    |> broadcast(:competition_participant_created)
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
    |> broadcast(:competition_participant_updated)
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

  def included_in_competition_period?(
        %CompetitionParticipant{} = competition_participant,
        start_date,
        end_date
      ) do
    included_in_competition_period?(
      Date.from_iso8601!(competition_participant.score_data["start_date"]),
      Date.from_iso8601!(competition_participant.score_data["end_date"]),
      start_date,
      end_date
    )
  end

  def included_in_competition_period?(
        %Date{} = comp_start_date,
        %Date{} = comp_end_date,
        %Date{} = act_start_date,
        %Date{} = act_end_date
      ) do
    # Since we test that the competition start_date is before the competition end_date:
    # if act_end_date <= comp_end_date
    if Date.compare(act_end_date, comp_end_date) != :gt do
      # act_end_date >= comp_start_date
      Date.compare(act_end_date, comp_start_date) != :lt
    else
      # act_start_date <= comp_end_date
      Date.compare(act_start_date, comp_end_date) != :gt
    end
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

  @doc """
  Updates everything! This is the money shot
  """
  def update_from_strava(), do: update_from_strava(Competitions.current_competition())

  def update_from_strava(competition) do
    competition_participants = competition && for_competition(competition)

    if competition_participants do
      Enum.each(competition_participants, fn cp ->
        MayIsBikeMonth.StravaRequests.update_competition_participant_activities(cp)
      end)
    end
  end

  def update_calculated_score(%CompetitionParticipant{} = competition_participant) do
    update_competition_participant(competition_participant, %{
      score_data: calculate_scoring_data(competition_participant)
    })
  end

  def empty_score_data(nil), do: %{}

  def empty_score_data(competition_id) do
    competition = MayIsBikeMonth.Competitions.get_competition!(competition_id)

    calculate_scoring_periods_with_activities(nil, competition.periods)
    |> scoring_periods_with_scoring_data(competition.start_date, competition.end_date)
  end

  def calculate_scoring_data(%CompetitionParticipant{} = competition_participant) do
    competition =
      MayIsBikeMonth.Competitions.get_competition!(competition_participant.competition_id)

    calculate_scoring_data(competition_participant.id, competition)
  end

  defp calculate_scoring_data(competition_participant_id, competition) do
    calculate_scoring_periods_with_activities(competition_participant_id, competition.periods)
    |> scoring_periods_with_scoring_data(competition.start_date, competition.end_date)
  end

  # NOTE: this takes start_date and end_date so included_in_competition_period? doesn't need to load the competition
  defp scoring_periods_with_scoring_data(scoring_periods_with_activities, start_date, end_date) do
    score_data = dates_distance_elevation(scoring_periods_with_activities)

    Map.merge(score_data, %{
      "start_date" => Date.to_string(start_date),
      "end_date" => Date.to_string(end_date),
      "periods" => scoring_periods_with_activities,
      "score" => calculate_score(score_data["dates"], score_data["distance_meters"])
    })
  end

  # TODO: should be private except tests
  def calculate_scoring_periods_with_activities(
        competition_participant_id,
        periods
      ) do
    periods
    |> Enum.map(fn period ->
      period_activities_data(competition_participant_id, period)
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
        competition_participant_id,
        %{start_date: start_date, end_date: end_date}
      ) do
    period_dates =
      Date.range(start_date, end_date)
      |> MapSet.new()

    MayIsBikeMonth.CompetitionActivities.list_competition_activities(%{
      competition_participant_id: competition_participant_id,
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

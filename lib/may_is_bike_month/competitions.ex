defmodule MayIsBikeMonth.Competitions do
  @moduledoc """
  The Competitions context.
  """

  import Ecto.Query, warn: false
  alias MayIsBikeMonth.Repo

  alias MayIsBikeMonth.Competitions.Competition

  @doc """
  Returns the list of competitions.

  ## Examples

      iex> list_competitions()
      [%Competition{}, ...]

  """
  def list_competitions do
    Repo.all(Competition)
    |> Enum.map(&with_virtual_attributes/1)
  end

  def current_competition do
    Competition
    |> Repo.one()
    |> with_virtual_attributes()
  end

  @doc """
  Gets a single competition.

  Raises `Ecto.NoResultsError` if the Competition does not exist.

  ## Examples

      iex> get_competition!(123)
      %Competition{}

      iex> get_competition!(456)
      ** (Ecto.NoResultsError)

  """
  def get_competition!(id) do
    Repo.get!(Competition, id)
    |> with_virtual_attributes()
  end

  @doc """
  Creates a competition.

  ## Examples

      iex> create_competition(%{field: value})
      {:ok, %Competition{}}

      iex> create_competition(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_competition(attrs \\ %{}) do
    %Competition{}
    |> Competition.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a competition.

  ## Examples

      iex> update_competition(competition, %{field: new_value})
      {:ok, %Competition{}}

      iex> update_competition(competition, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_competition(%Competition{} = competition, attrs) do
    competition
    |> Competition.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a competition.

  ## Examples

      iex> delete_competition(competition)
      {:ok, %Competition{}}

      iex> delete_competition(competition)
      {:error, %Ecto.Changeset{}}

  """
  def delete_competition(%Competition{} = competition) do
    Repo.delete(competition)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking competition changes.

  ## Examples

      iex> change_competition(competition)
      %Ecto.Changeset{data: %Competition{}}

  """
  def change_competition(%Competition{} = competition, attrs \\ %{}) do
    Competition.changeset(competition, attrs)
  end

  def create_competition_participants(%Competition{} = competition) do
    MayIsBikeMonth.Participants.list_participants()
    |> Enum.map(fn participant ->
      MayIsBikeMonth.CompetitionParticipants.create_competition_participant(%{
        competition_id: competition.id,
        participant_id: participant.id
      })
    end)
  end

  def competition_periods(%Competition{} = competition) do
    competition_periods(competition.start_date, competition.end_date)
  end

  def competition_periods(start_date, end_date) do
    end_date_periods =
      Date.range(start_date, end_date)
      |> Enum.filter(fn date -> Date.day_of_week(date) == 7 end)
      |> Enum.map(fn date -> %{end_date: date} end)
      |> Enum.map(fn map -> Map.put(map, :start_date, week_start(map.end_date)) end)

    last_day = List.last(end_date_periods).end_date

    if last_day == end_date do
      end_date_periods
    else
      end_date_periods ++ [%{start_date: Date.add(last_day, 1), end_date: end_date}]
    end
  end

  defp week_start(date) do
    monday = Date.add(date, -6)
    Enum.max([monday, Date.beginning_of_month(date)], Date)
  end

  defp with_virtual_attributes(nil), do: nil

  defp with_virtual_attributes(%Competition{} = competition) do
    competition
    |> with_periods()
    |> with_active()
  end

  defp with_periods(%Competition{} = competition) do
    %{competition | periods: competition_periods(competition)}
  end

  def competition_active?(%Competition{} = competition),
    do: competition_active?(competition.start_date, competition.end_date)

  def competition_active?(start_date, end_date) do
    today = Date.utc_today()

    start_date && end_date && Date.compare(today, start_date) != :lt &&
      Date.compare(today, end_date) != :gt
  end

  defp with_active(%Competition{} = competition) do
    %{competition | active: competition_active?(competition)}
  end
end

defmodule MayIsBikeMonth.CompetitionActivities do
  @moduledoc """
  The CompetitionActivities context.
  """

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

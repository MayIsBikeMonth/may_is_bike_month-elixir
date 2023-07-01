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
  def get_competition!(id), do: Repo.get!(Competition, id)

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
end

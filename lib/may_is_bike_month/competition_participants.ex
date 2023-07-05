defmodule MayIsBikeMonth.CompetitionParticipants do
  @moduledoc """
  The CompetitionParticipants context.
  """

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
    Repo.all(CompetitionParticipant)
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
end

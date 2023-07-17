defmodule MayIsBikeMonth.Participants do
  @moduledoc """
  The Participants context.
  """

  import Ecto.Query, warn: false
  alias MayIsBikeMonth.Repo

  alias MayIsBikeMonth.{Participants.Participant, Participants.StravaToken, Strava}

  @doc """
  Returns the list of participants.

  ## Examples

      iex> list_participants()
      [%Participant{}, ...]

  """
  def list_participants(opts) do
    Repo.all(from p in Participant, limit: ^Keyword.fetch!(opts, :limit))
  end

  def list_participants, do: list_participants(limit: 100)

  @doc """
  Gets a single participant.

  Raises `Ecto.NoResultsError` if the Participant does not exist.

  ## Examples

      iex> get_participant!(123)
      %Participant{}

      iex> get_participant!(456)
      ** (Ecto.NoResultsError)

  """
  def get_participant!(id), do: Repo.get!(Participant, id)

  def get_participant(id), do: Repo.get(Participant, id)

  def get_participant_by_strava_id(strava_id) do
    strava_id_string = to_string(strava_id)

    from(p in Participant, where: p.strava_id == ^strava_id_string)
    |> Repo.one()
  end

  def admin?(%Participant{} = participant) do
    participant.strava_id in MayIsBikeMonth.config([:strava, :admin_ids])
  end

  @doc """
  Returns the list of strava_tokens.

  ## Examples

      iex> list_strava_tokens()
      [%Participant{}, ...]

  """
  def list_strava_tokens(opts) do
    from(st in StravaToken,
      limit: ^Keyword.fetch!(opts, :limit),
      order_by: [desc: :id]
    )
    |> Repo.all()
    |> Enum.map(&strava_token_with_expired/1)
  end

  def list_strava_tokens, do: list_strava_tokens(limit: 100)

  def strava_token_for_participant(%Participant{} = participant) do
    from(StravaToken, order_by: [desc: :id])
    |> where(participant_id: ^participant.id)
    |> first()
    |> Repo.one()
    |> strava_token_with_expired()
  end

  @doc """
  Creates a strava_token

  """
  def create_strava_token(participant_id, access, refresh, expires_at, meta \\ %{}) do
    %StravaToken{}
    |> StravaToken.changeset(%{
      access_token: access,
      refresh_token: refresh,
      expires_at: DateTime.from_unix!(expires_at),
      strava_meta: meta,
      participant_id: participant_id
    })
    |> Repo.insert()
  end

  def participant_from_strava_token_response(access, refresh, expires_at, meta) do
    {:ok, participant} = create_or_update_participant(meta)
    {:ok, _} = create_strava_token(participant.id, access, refresh, expires_at, meta)
    {:ok, participant}
  end

  def participant_from_strava_token_response(token_response) do
    %{
      "access_token" => access,
      "refresh_token" => refresh,
      "expires_at" => expires_at,
      "athlete" => meta,
      "token_type" => "Bearer",
      "expires_in" => _
    } = token_response

    participant_from_strava_token_response(access, refresh, expires_at, meta)
  end

  @doc """
  Finds and updates or creates a participant using the strava data that is passed in
  This is how all participants should be created!
  """
  def create_or_update_participant(strava_data) do
    attrs = %{
      strava_id: to_string(strava_data["id"]),
      first_name: strava_data["firstname"],
      last_name: strava_data["lastname"],
      strava_username: strava_data["username"],
      image_url: strava_data["profile"]
    }

    if participant = get_participant_by_strava_id(attrs.strava_id) do
      update_participant(participant, attrs)
    else
      create_participant(attrs)
    end
  end

  def refreshed_access_token(%StravaToken{} = strava_token) do
    {:ok, response} = Strava.refresh_access_token(strava_token.refresh_token)

    if response do
      %{
        "access_token" => access,
        "refresh_token" => refresh,
        "expires_at" => expires_at,
        "token_type" => "Bearer",
        "expires_in" => _
      } = response

      create_strava_token(strava_token.participant_id, access, refresh, expires_at)
    else
      {:error, "Unable to refresh access token"}
    end
  end

  @doc """
  Creates a participant.

  ## Examples

      iex> create_participant(%{field: value})
      {:ok, %Participant{}}

      iex> create_participant(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_participant(attrs \\ %{}) do
    %Participant{}
    |> Participant.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a participant.

  ## Examples

      iex> update_participant(participant, %{field: new_value})
      {:ok, %Participant{}}

      iex> update_participant(participant, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_participant(%Participant{} = participant, attrs) do
    participant
    |> Participant.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a participant.

  ## Examples

      iex> delete_participant(participant)
      {:ok, %Participant{}}

      iex> delete_participant(participant)
      {:error, %Ecto.Changeset{}}

  """
  def delete_participant(%Participant{} = participant) do
    Repo.delete(participant)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking participant changes.

  ## Examples

      iex> change_participant(participant)
      %Ecto.Changeset{data: %Participant{}}

  """
  def change_participant(%Participant{} = participant, attrs \\ %{}) do
    Participant.changeset(participant, attrs)
  end

  # Virtual attribute setting!
  defp strava_token_with_expired(%StravaToken{} = strava_token) do
    %{strava_token | expired: DateTime.utc_now() > strava_token.expires_at}
  end
end

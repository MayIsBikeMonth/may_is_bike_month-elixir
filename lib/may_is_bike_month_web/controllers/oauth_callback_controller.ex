defmodule MayIsBikeMonthWeb.OAuthCallbackController do
  use MayIsBikeMonthWeb, :controller
  require Logger

  alias MayIsBikeMonth.Participants

  def new(conn, %{"provider" => "strava", "code" => code}) do
    client = strava_client(conn)

    with {:ok, info} <- client.exchange_access_token(code: code),
         {:ok, participant} <- Participants.participant_from_strava_token_response(info),
         {:ok, competition_participant} <- create_competition_participant(participant) do
      MayIsBikeMonth.StravaRequests.update_competition_participant_activities(
        competition_participant
      )

      conn
      |> put_flash(:info, "Welcome #{participant.display_name}")
      |> MayIsBikeMonthWeb.ParticipantAuth.log_in_participant(participant)
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        Logger.debug("failed Strava insert #{inspect(changeset.errors)}")

        conn
        |> put_flash(
          :error,
          "We were unable to fetch the necessary information from your Strava account"
        )
        |> redirect(to: "/")

      {:error, reason} ->
        Logger.debug("failed Strava exchange #{inspect(reason)}")

        conn
        |> put_flash(:error, "We were unable to contact Strava. Please try again later")
        |> redirect(to: "/")
    end
  end

  def new(conn, %{"provider" => "strava", "error" => "access_denied"}) do
    redirect(conn, to: "/")
  end

  def sign_out(conn, _) do
    MayIsBikeMonthWeb.ParticipantAuth.log_out_participant(conn)
  end

  defp strava_client(conn) do
    conn.assigns[:strava_client] || MayIsBikeMonth.Strava
  end

  defp create_competition_participant(participant) do
    competition = MayIsBikeMonth.Competitions.current_competition()
    # Maybe only do this if current_competition.active ?
    # For now, to get things rolling - just making it happen
    if competition do
      MayIsBikeMonth.CompetitionParticipants.create_competition_participant(%{
        competition_id: competition.id,
        participant_id: participant.id,
        include_in_competition: true
      })
    else
      {:error, "No current competition"}
    end
  end
end

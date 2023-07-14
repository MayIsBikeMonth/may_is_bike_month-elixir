defmodule MayIsBikeMonthWeb.OAuthCallbackController do
  use MayIsBikeMonthWeb, :controller
  require Logger

  alias MayIsBikeMonth.Participants

  def new(conn, %{"provider" => "strava", "code" => code, "state" => state}) do
    client = strava_client(conn)

    with {:ok, info} <- client.exchange_access_token(code: code, state: state),
         %{info: info, primary_email: primary, emails: emails, token: token} = info,
         {:ok, participant} <- Participants.create_participant(primary, info, emails, token) do
      conn
      |> put_flash(:info, "Welcome #{participant.display_name}")
      |> MayIsBikeMonthWeb.PartcipantAuth.log_in_participant(participant)
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        Logger.debug("failed GitHub insert #{inspect(changeset.errors)}")

        conn
        |> put_flash(
          :error,
          "We were unable to fetch the necessary information from your GithHub account"
        )
        |> redirect(to: "/")

      {:error, reason} ->
        Logger.debug("failed GitHub exchange #{inspect(reason)}")

        conn
        |> put_flash(:error, "We were unable to contact GitHub. Please try again later")
        |> redirect(to: "/")
    end
  end

  def new(conn, %{"provider" => "strava", "error" => "access_denied"}) do
    redirect(conn, to: "/")
  end

  def sign_out(conn, _) do
    MayIsBikeMonthWeb.PartcipantAuth.log_out_participant(conn)
  end

  defp strava_client(conn) do
    conn.assigns[:strava_client] || MayIsBikeMonth.Strava
  end
end

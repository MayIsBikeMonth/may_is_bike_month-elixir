defmodule MayIsBikeMonthWeb.PageController do
  use MayIsBikeMonthWeb, :controller

  def home(conn, _params) do
    competition = MayIsBikeMonth.Competitions.current_competition()

    if competition do
      competition_participants =
        MayIsBikeMonth.CompetitionParticipants.for_competition(competition)

      render(conn, :competition,
        competition: competition,
        competition_participants: competition_participants
      )
    else
      render(conn, :home)
    end
  end

  def update_strava(conn, _params) do
    # MayIsBikeMonth.CompetitionParticipants.update_from_strava_if_due()
    json(conn, %{message: "success"})
  end
end

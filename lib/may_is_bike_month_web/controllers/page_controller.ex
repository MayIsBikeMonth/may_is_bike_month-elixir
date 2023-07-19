defmodule MayIsBikeMonthWeb.PageController do
  use MayIsBikeMonthWeb, :controller

  def home(conn, _params) do
    competition = MayIsBikeMonth.Competitions.current_competition()

    if competition do
      competition_participants =
        MayIsBikeMonth.CompetitionParticipants.for_competition(competition)

      # TODO, call this in the background or a socket or something
      MayIsBikeMonth.CompetitionParticipants.update_from_strava_if_due()

      render(conn, :competition,
        competition: competition,
        competition_participants: competition_participants
      )
    else
      render(conn, :home)
    end
  end
end

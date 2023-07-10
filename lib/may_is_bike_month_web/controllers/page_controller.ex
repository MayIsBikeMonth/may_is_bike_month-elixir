defmodule MayIsBikeMonthWeb.PageController do
  use MayIsBikeMonthWeb, :controller
  import Number.Delimit

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
end

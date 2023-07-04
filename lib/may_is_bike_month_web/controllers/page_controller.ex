defmodule MayIsBikeMonthWeb.PageController do
  use MayIsBikeMonthWeb, :controller

  def home(conn, _params) do
    competition = MayIsBikeMonth.Competitions.current_competition()

    if competition do
      participants = MayIsBikeMonth.Participants.list_participants()
      render(conn, :competition, competition: competition, participants: participants)
    else
      render(conn, :home)
    end
  end
end

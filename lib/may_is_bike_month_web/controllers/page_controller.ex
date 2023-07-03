defmodule MayIsBikeMonthWeb.PageController do
  use MayIsBikeMonthWeb, :controller

  def home(conn, _params) do
    competition = MayIsBikeMonth.Competitions.current_competition()

    if competition do
      render(conn, :competition, competition: competition)
    else
      render(conn, :home)
    end
  end
end

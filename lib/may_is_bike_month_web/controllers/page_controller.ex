defmodule MayIsBikeMonthWeb.PageController do
  use MayIsBikeMonthWeb, :controller

  def home(conn, _params) do
    competition = MayIsBikeMonth.Competitions.current_competition()
    render(conn, :home, competition: competition)
  end
end

defmodule MayIsBikeMonthWeb.StravaRequestLive.Index do
  use MayIsBikeMonthWeb, :live_view

  alias MayIsBikeMonth.{StravaRequests, CompetitionParticipants}

  @impl true
  def mount(_params, _session, socket) do
    CompetitionParticipants.update_from_strava_if_due()

    {:ok,
     stream(
       socket,
       :strava_requests,
       StravaRequests.list_strava_requests_load_participant()
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Strava requests")
    |> assign(:strava_request, nil)
  end
end

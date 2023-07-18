defmodule MayIsBikeMonthWeb.StravaRequestLive.Show do
  use MayIsBikeMonthWeb, :live_view

  alias MayIsBikeMonth.StravaRequests

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:strava_request, StravaRequests.get_strava_request!(id))}
  end

  defp page_title(:show), do: "Show Strava request"
  defp page_title(:edit), do: "Edit Strava request"
end

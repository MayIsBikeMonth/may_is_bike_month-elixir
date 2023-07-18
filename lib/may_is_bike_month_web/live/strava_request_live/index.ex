defmodule MayIsBikeMonthWeb.StravaRequestLive.Index do
  use MayIsBikeMonthWeb, :live_view

  alias MayIsBikeMonth.StravaRequests
  alias MayIsBikeMonth.StravaRequests.StravaRequest

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :strava_requests, StravaRequests.list_strava_requests())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Strava request")
    |> assign(:strava_request, StravaRequests.get_strava_request!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Strava request")
    |> assign(:strava_request, %StravaRequest{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Strava requests")
    |> assign(:strava_request, nil)
  end

  @impl true
  def handle_info({MayIsBikeMonthWeb.StravaRequestLive.FormComponent, {:saved, strava_request}}, socket) do
    {:noreply, stream_insert(socket, :strava_requests, strava_request)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    strava_request = StravaRequests.get_strava_request!(id)
    {:ok, _} = StravaRequests.delete_strava_request(strava_request)

    {:noreply, stream_delete(socket, :strava_requests, strava_request)}
  end
end

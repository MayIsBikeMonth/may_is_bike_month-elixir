defmodule MayIsBikeMonthWeb.StravaRequestLive.FormComponent do
  use MayIsBikeMonthWeb, :live_component

  alias MayIsBikeMonth.StravaRequests

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage strava_request records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="strava_request-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:type]} type="number" label="Type" />
        <.input field={@form[:status]} type="number" label="Status" />
        <.input field={@form[:error_response]} type="text" label="Error response" />
        <.input field={@form[:options]} type="text" label="Options" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Strava request</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{strava_request: strava_request} = assigns, socket) do
    changeset = StravaRequests.change_strava_request(strava_request)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"strava_request" => strava_request_params}, socket) do
    changeset =
      socket.assigns.strava_request
      |> StravaRequests.change_strava_request(strava_request_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"strava_request" => strava_request_params}, socket) do
    save_strava_request(socket, socket.assigns.action, strava_request_params)
  end

  defp save_strava_request(socket, :edit, strava_request_params) do
    case StravaRequests.update_strava_request(socket.assigns.strava_request, strava_request_params) do
      {:ok, strava_request} ->
        notify_parent({:saved, strava_request})

        {:noreply,
         socket
         |> put_flash(:info, "Strava request updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_strava_request(socket, :new, strava_request_params) do
    case StravaRequests.create_strava_request(strava_request_params) do
      {:ok, strava_request} ->
        notify_parent({:saved, strava_request})

        {:noreply,
         socket
         |> put_flash(:info, "Strava request created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end

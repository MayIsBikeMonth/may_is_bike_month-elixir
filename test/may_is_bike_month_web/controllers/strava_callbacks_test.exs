defmodule MayIsBikeMonthWeb.StravaCallbackTest do
  # use MayIsBikeMonthWeb.ConnCase, async: true

  # alias MayIsBikeMonth.Participants

  # def exchange_access_token(opts) do
  #   _code = opts[:code]
  #   state = opts[:state]

  #   case state do
  #     "valid" ->
  #       {:ok, example_strava_token_response()}

  #     "invalid" ->
  #       {:error, %{reason: "token"}}

  #     "failed" ->
  #       {:error, %{reason: state}}
  #   end
  # end

  # setup %{conn: conn} do
  #   conn = assign(conn, :strava_client, __MODULE__)

  #   {:ok, conn: conn}
  # end

  # test "callback with valid token", %{conn: conn} do
  #   params = %{"code" => "91ec7d9d3b505239bebf98d2285b80deb7bddfd7"}

  #   assert Participants.get_participant_by_strava_id("2430215") == nil

  #   conn = get(conn, ~p"/oauth/callbacks/strava?#{params}")

  #   assert redirected_to(conn, 302) == "/"

  #   assert %Participants.Participant{} =
  #            participant = Participants.get_participant_by_strava_id(2_430_215)

  #   assert participant.display_name == "sethherr"
  # end

  # test "callback with invalid exchange response", %{conn: conn} do
  #   params = %{"code" => "66e1c4202275d071eced", "state" => "invalid"}
  #   assert Participants.list_participants(limit: 100) == []

  #   conn = get(conn, ~p"/oauth/callbacks/strava?#{params}")

  #   assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
  #            "We were unable to contact Strava. Please try again later"

  #   assert redirected_to(conn, 302) == "/"
  #   assert Participants.list_participants(limit: 100) == []
  # end

  # test "callback with failed token exchange", %{conn: conn} do
  #   params = %{"code" => "66e1c4202275d071eced", "state" => "failed"}

  #   assert Participants.list_participants(limit: 100) == []

  #   conn = get(conn, ~p"/oauth/callbacks/strava?#{params}")

  #   assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
  #            "We were unable to contact Strava. Please try again later"

  #   assert redirected_to(conn, 302) == "/"
  #   assert Participants.list_participants(limit: 100) == []
  # end
end

defmodule MayIsBikeMonthWeb.StravaCallbackTest do
  use MayIsBikeMonthWeb.ConnCase, async: true

  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias MayIsBikeMonth.Participants

  setup do
    ExVCR.Config.cassette_library_dir("test/support/vcr_cassettes")

    ExVCR.Config.filter_sensitive_data(
      MayIsBikeMonth.config([:strava, :client_secret]),
      "STRAVA_SECRET"
    )

    HTTPoison.start()
    :ok
  end

  test "callback with valid token", %{conn: conn} do
    use_cassette "exchange_access_token_success" do
      params = %{"code" => "valid-code"}

      assert Participants.get_participant_by_strava_id("2430215") == nil
      assert Participants.list_strava_tokens() == []

      conn = get(conn, ~p"/oauth/callbacks/strava?#{params}")

      assert redirected_to(conn, 302) == "/"

      assert %Participants.Participant{} =
               participant = Participants.get_participant_by_strava_id(2_430_215)

      assert participant.display_name == "sethherr"

      assert Enum.count(Participants.list_strava_tokens()) == 1
      strava_token = Participants.strava_token_for_participant(participant)
      assert strava_token.access_token == "xxxxxxx"
      assert strava_token.refresh_token == "yyyyyyy"
      assert strava_token.expired == false
    end
  end

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

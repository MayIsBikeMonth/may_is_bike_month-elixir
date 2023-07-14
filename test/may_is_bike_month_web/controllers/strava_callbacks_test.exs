defmodule MayIsBikeMonthWeb.StravaCallbackTest do
  use MayIsBikeMonthWeb.ConnCase, async: true

  alias MayIsBikeMonth.Participants

  def exchange_access_token(opts) do
    _code = opts[:code]
    state = opts[:state]

    case state do
      "valid" ->
        {:ok,
         %{
           info: %{
             "login" => "chrismccord",
             "name" => "Chris",
             "id" => 1,
             "avatar_url" => "",
             "html_url" => ""
           },
           primary_email: "chris@local.test",
           emails: [%{"primary" => true, "email" => "chris@local.test"}],
           token: "1234"
         }}

      "invalid" ->
        {:error, %{reason: "token"}}

      "failed" ->
        {:error, %{reason: state}}
    end
  end

  setup %{conn: conn} do
    conn = assign(conn, :strava_client, __MODULE__)

    {:ok, conn: conn}
  end

  test "callback with valid token", %{conn: conn} do
    params = %{"code" => "66e1c4202275d071eced", "state" => "valid"}

    assert Participants.get_participant_by_strava_id("2430215") == nil

    conn = get(conn, ~p"/oauth/callbacks/strava?#{params}")

    assert redirected_to(conn, 302) == "/chrismccord"

    assert %Participants.Participant{} =
             participant = Participants.get_participant_by_strava_id(2_430_215)

    assert participant.display_name == "sethherr"
  end

  test "callback with invalid exchange response", %{conn: conn} do
    params = %{"code" => "66e1c4202275d071eced", "state" => "invalid"}
    assert Participants.list_participants(limit: 100) == []

    conn = get(conn, ~p"/oauth/callbacks/strava?#{params}")

    assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
             "We were unable to contact Strava. Please try again later"

    assert redirected_to(conn, 302) == "/"
    assert Participants.list_participants(limit: 100) == []
  end

  test "callback with failed token exchange", %{conn: conn} do
    params = %{"code" => "66e1c4202275d071eced", "state" => "failed"}

    assert Participants.list_participants(limit: 100) == []

    conn = get(conn, ~p"/oauth/callbacks/strava?#{params}")

    assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
             "We were unable to contact Strava. Please try again later"

    assert redirected_to(conn, 302) == "/"
    assert Participants.list_participants(limit: 100) == []
  end
end

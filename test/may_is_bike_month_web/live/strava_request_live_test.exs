defmodule MayIsBikeMonthWeb.StravaRequestLiveTest do
  use MayIsBikeMonthWeb.ConnCase

  import Phoenix.LiveViewTest
  import MayIsBikeMonth.StravaRequestsFixtures

  @create_attrs %{error_response: %{}, options: %{}, status: 42, type: 42}
  @update_attrs %{error_response: %{}, options: %{}, status: 43, type: 43}
  @invalid_attrs %{error_response: nil, options: nil, status: nil, type: nil}

  defp create_strava_request(_) do
    strava_request = strava_request_fixture()
    %{strava_request: strava_request}
  end

  describe "Index" do
    setup [:create_strava_request]

    test "lists all strava_requests", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/strava_requests")

      assert html =~ "Listing Strava requests"
    end

    test "saves new strava_request", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/strava_requests")

      assert index_live |> element("a", "New Strava request") |> render_click() =~
               "New Strava request"

      assert_patch(index_live, ~p"/strava_requests/new")

      assert index_live
             |> form("#strava_request-form", strava_request: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#strava_request-form", strava_request: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/strava_requests")

      html = render(index_live)
      assert html =~ "Strava request created successfully"
    end

    test "updates strava_request in listing", %{conn: conn, strava_request: strava_request} do
      {:ok, index_live, _html} = live(conn, ~p"/strava_requests")

      assert index_live |> element("#strava_requests-#{strava_request.id} a", "Edit") |> render_click() =~
               "Edit Strava request"

      assert_patch(index_live, ~p"/strava_requests/#{strava_request}/edit")

      assert index_live
             |> form("#strava_request-form", strava_request: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#strava_request-form", strava_request: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/strava_requests")

      html = render(index_live)
      assert html =~ "Strava request updated successfully"
    end

    test "deletes strava_request in listing", %{conn: conn, strava_request: strava_request} do
      {:ok, index_live, _html} = live(conn, ~p"/strava_requests")

      assert index_live |> element("#strava_requests-#{strava_request.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#strava_requests-#{strava_request.id}")
    end
  end

  describe "Show" do
    setup [:create_strava_request]

    test "displays strava_request", %{conn: conn, strava_request: strava_request} do
      {:ok, _show_live, html} = live(conn, ~p"/strava_requests/#{strava_request}")

      assert html =~ "Show Strava request"
    end

    test "updates strava_request within modal", %{conn: conn, strava_request: strava_request} do
      {:ok, show_live, _html} = live(conn, ~p"/strava_requests/#{strava_request}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Strava request"

      assert_patch(show_live, ~p"/strava_requests/#{strava_request}/show/edit")

      assert show_live
             |> form("#strava_request-form", strava_request: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#strava_request-form", strava_request: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/strava_requests/#{strava_request}")

      html = render(show_live)
      assert html =~ "Strava request updated successfully"
    end
  end
end

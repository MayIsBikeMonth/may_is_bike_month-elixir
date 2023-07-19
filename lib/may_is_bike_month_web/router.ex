defmodule MayIsBikeMonthWeb.Router do
  use MayIsBikeMonthWeb, :router
  use Honeybadger.Plug

  import MayIsBikeMonthWeb.ParticipantAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {MayIsBikeMonthWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_participant
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MayIsBikeMonthWeb do
    pipe_through :browser

    get "/", PageController, :home

    live_session :default,
      on_mount: [{MayIsBikeMonthWeb.ParticipantAuth, :current_participant}] do
      live "/strava_requests", StravaRequestLive.Index, :index
    end
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:may_is_bike_month, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: MayIsBikeMonthWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes
  scope "/", MayIsBikeMonthWeb do
    pipe_through [:browser, :redirect_if_participant_is_authenticated]

    get "/oauth/callbacks/:provider", OAuthCallbackController, :new
  end

  scope "/", MayIsBikeMonthWeb do
    pipe_through [:browser]

    delete "/signout", OAuthCallbackController, :sign_out
  end

  use Kaffy.Routes, scope: "/admin", pipe_through: [:browser, :require_authenticated_admin]
end

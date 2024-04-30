# MayIsBikeMonth

This is a [Phoenix App](https://www.phoenixframework.org/) to track the score and generate the leaderboard for the May is Bike Month group.

It's pretty silly and definitely doesn't do everything correctly, but was a fun way to learn a little Phoenix and Elixir.

## Running locally

Copy the `.env.example` file to `.env` and fill in the values for your [Strava app](https://www.strava.com/settings/api)

To start the Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4003`](http://localhost:4003) from your browser.

To run the tests and rerun on save:

  * Run `mix test.watch --stale`
  * If you want to just rerun failing tests until the pass, run `mix test.watch --failed`

---

Admin interface is accessible via

https://may-is-bike-month.fly.dev/admin

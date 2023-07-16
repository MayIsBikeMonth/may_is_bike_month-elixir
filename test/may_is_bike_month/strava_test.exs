defmodule MayIsBikeMonth.StravaTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias MayIsBikeMonth.Strava

  # TODO:
  # - Add test for getting activities

  setup do
    ExVCR.Config.cassette_library_dir("test/support/vcr_cassettes")

    ExVCR.Config.filter_sensitive_data(
      MayIsBikeMonth.config([:strava, :client_secret]),
      "STRAVA_SECRET"
    )

    HTTPoison.start()
    :ok
  end

  describe "exchange_access_token" do
    test "with valid code" do
      use_cassette "exchange_access_token_success" do
        {:ok, info} =
          Strava.exchange_access_token(code: "e8ab449eb83bd71b3ddc81d0a7a5c77b7ad0685f")

        assert info["access_token"]
        assert info["athlete"]["id"] == 2_430_215
      end
    end

    test "with invalid code" do
      use_cassette "exchange_access_token-fail" do
        {:error, errors} =
          Strava.exchange_access_token(code: "e8ab449eb83bd71b3ddc81d0a7a5c77b7ad0685f")

        assert errors["message"] == "Bad Request"
      end
    end
  end
end

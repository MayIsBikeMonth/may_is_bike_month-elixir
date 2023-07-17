defmodule MayIsBikeMonth.StravaTest do
  use MayIsBikeMonth.DataCase
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias MayIsBikeMonth.Strava

  import MayIsBikeMonth.StravaTokensFixtures

  setup do
    setup_vcr()
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

  describe "refresh_access_token" do
    test "with valid access_token" do
      use_cassette "refresh_access_token-success" do
        strava_token =
          strava_token_fixture(%{
            "access_token" => "xxxxxx",
            "refresh_token" => "yyyyyyy",
            "expires_at" => token_expires_at(-1000)
          })

        assert strava_token.access_token == "xxxxxx"
        assert strava_token.expired == true
        {:ok, new_strava_token} = Strava.refresh_access_token(strava_token.refresh_token)
        assert new_strava_token["access_token"] == "xxxxxx"
        assert new_strava_token["refresh_token"] == strava_token.refresh_token
      end
    end
  end
end

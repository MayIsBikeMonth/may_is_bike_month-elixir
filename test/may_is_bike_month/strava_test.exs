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
      use_cassette "exchange_access_token-success" do
        {:ok, info} =
          Strava.exchange_access_token(code: "e8ab449eb83bd71b3ddc81d0a7a5c77b7ad0685f")

        assert info["access_token"]
        assert info["athlete"]["id"] == 2_430_215
      end
    end

    test "with invalid code" do
      use_cassette "exchange_access_token-fail" do
        {:error, error_response} =
          Strava.exchange_access_token(code: "e8ab449eb83bd71b3ddc81d0a7a5c77b7ad0685f")

        assert Map.keys(error_response) == [:status, :body]
        assert error_response.status == 400
        assert error_response.body["message"] == "Bad Request"
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
        assert strava_token.active == false
        {:ok, new_token_response} = Strava.refresh_access_token(strava_token.refresh_token)
        assert new_token_response["access_token"] == "xxxxxx"
        assert new_token_response["refresh_token"] == strava_token.refresh_token
      end
    end

    test "with invalid access_token" do
      use_cassette "refresh_access_token-fail" do
        strava_token =
          strava_token_fixture(%{
            "access_token" => "xxxxxx",
            "refresh_token" => "yyyyyyy",
            "expires_at" => token_expires_at(-1000)
          })

        assert strava_token.access_token == "xxxxxx"
        assert strava_token.active == false
        {:error, error_response} = Strava.refresh_access_token(strava_token.refresh_token)
        assert error_response.status == 400
        assert(error_response.body["message"] == "Bad Request")
      end
    end
  end

  describe "get_activities" do
    test "success" do
      use_cassette "get_activities-success" do
        access_token = "xxxxxx"
        {:ok, activities_response} = Strava.get_activities(access_token, %{per_page: 1})
        assert Enum.count(activities_response) == 1
      end
    end

    test "error" do
      use_cassette "get_activities-fail" do
        access_token = "xxxxxx"
        {:error, error_response} = Strava.get_activities(access_token, %{per_page: 1})

        assert Map.keys(error_response) == [:status, :body]
        assert error_response.status == 401

        assert error_response.body == %{
                 "errors" => [
                   %{"code" => "invalid", "field" => "access_token", "resource" => "Athlete"}
                 ],
                 "message" => "Authorization Error"
               }
      end
    end
  end
end

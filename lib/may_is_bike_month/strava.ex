defmodule MayIsBikeMonth.Strava do
  def authorize_url() do
    "https://strava.com/login/oauth/authorize?client_id=#{client_id()}&scope=activity:read_all,profile:read_all"
  end

  def exchange_access_token(opts) do
    code = Keyword.fetch!(opts, :code)

    code
    |> fetch_exchange_response()

    # It doesn't seem like we need to actually make this call,
    # enough information is returned in the original response
    # |> fetch_participant_info()
  end

  defp fetch_exchange_response(code) do
    resp =
      http(
        "www.strava.com",
        "POST",
        "/api/v3/oauth/token",
        [code: code, client_secret: secret()],
        [{"accept", "application/json"}]
      )

    with {:ok, resp} <- resp,
         %{"access_token" => token} <- Jason.decode!(resp) do
      {:ok, token}
    else
      {:error, _reason} = err -> err
      %{} = resp -> {:error, {:bad_response, resp}}
    end
  end

  # defp fetch_participant_info({:error, _reason} = error), do: error
  # defp fetch_participant_info({:ok, token}) do
  #   resp =
  #     http(
  #       "www.strava.com",
  #       "GET",
  #       "/api/v3/athlete",
  #       [],
  #       [{"accept", "application/json"}, {"Authorization", "Bearer #{token}"}]
  #     )

  #   case resp do
  #     {:ok, info} -> {:ok, %{info: Jason.decode!(info), token: token}}
  #     {:error, _reason} = err -> err
  #   end
  # end

  defp client_id, do: MayIsBikeMonth.config([:strava, :client_id])
  defp secret, do: MayIsBikeMonth.config([:strava, :client_secret])

  defp http(host, method, path, query, headers, body \\ "") do
    {:ok, conn} = Mint.HTTP.connect(:https, host, 443)

    path = path <> "?" <> URI.encode_query([{:client_id, client_id()} | query])

    {:ok, conn, ref} =
      Mint.HTTP.request(
        conn,
        method,
        path,
        headers,
        body
      )

    receive_resp(conn, ref, nil, nil, false)
  end

  defp receive_resp(conn, ref, status, data, done?) do
    receive do
      message ->
        {:ok, conn, responses} = Mint.HTTP.stream(conn, message)

        {new_status, new_data, done?} =
          Enum.reduce(responses, {status, data, done?}, fn
            {:status, ^ref, new_status}, {_old_status, data, done?} -> {new_status, data, done?}
            {:headers, ^ref, _headers}, acc -> acc
            {:data, ^ref, binary}, {status, nil, done?} -> {status, binary, done?}
            {:data, ^ref, binary}, {status, data, done?} -> {status, data <> binary, done?}
            {:done, ^ref}, {status, data, _done?} -> {status, data, true}
          end)

        cond do
          done? and new_status == 200 -> {:ok, new_data}
          done? -> {:error, {new_status, new_data}}
          !done? -> receive_resp(conn, ref, new_status, new_data, done?)
        end
    end
  end
end

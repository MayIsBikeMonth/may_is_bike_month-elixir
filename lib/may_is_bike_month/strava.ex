defmodule MayIsBikeMonth.Strava do
  def authorize_url() do
    "http://www.strava.com/oauth/authorize?client_id=#{client_id()}&response_type=code&scope=activity:read_all,profile:read_all&redirect_uri=#{redirect_uri()}"
  end

  def exchange_access_token(opts) do
    Keyword.fetch!(opts, :code)
    |> fetch_exchange_response()
  end

  defp fetch_exchange_response(code) do
    url = "https://www.strava.com/oauth/token?grant_type=authorization_code"
    body = Jason.encode!(%{code: code, client_secret: secret(), client_id: client_id()})
    resp = HTTPoison.post(url, body, [{"Content-Type", "application/json"}])

    case resp do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %HTTPoison.Response{status_code: 400, body: body}} ->
        {:error, Jason.decode!(body)}

      {:error, %HTTPoison.Error{reason: reason}} ->
        reason
    end
  end

  defp client_id, do: MayIsBikeMonth.config([:strava, :client_id])
  defp secret, do: MayIsBikeMonth.config([:strava, :client_secret])
  defp redirect_uri, do: "#{redirect_domain()}/oauth/callbacks/strava"
  defp redirect_domain, do: MayIsBikeMonth.config([:strava, :redirect_domain])

  # defp http(host, method, path, query, headers, body \\ "") do
  #   {:ok, conn} = Mint.HTTP.connect(:https, host, 443)

  #   path = path <> "?" <> URI.encode_query([{:client_id, client_id()} | query])

  #   {:ok, conn, ref} =
  #     Mint.HTTP.request(
  #       conn,
  #       method,
  #       path,
  #       headers,
  #       body
  #     )

  #   receive_resp(conn, ref, nil, nil, false)
  # end

  # defp receive_resp(conn, ref, status, data, done?) do
  #   receive do
  #     message ->
  #       {:ok, conn, responses} = Mint.HTTP.stream(conn, message)

  #       {new_status, new_data, done?} =
  #         Enum.reduce(responses, {status, data, done?}, fn
  #           {:status, ^ref, new_status}, {_old_status, data, done?} -> {new_status, data, done?}
  #           {:headers, ^ref, _headers}, acc -> acc
  #           {:data, ^ref, binary}, {status, nil, done?} -> {status, binary, done?}
  #           {:data, ^ref, binary}, {status, data, done?} -> {status, data <> binary, done?}
  #           {:done, ^ref}, {status, data, _done?} -> {status, data, true}
  #         end)

  #       cond do
  #         done? and new_status == 200 -> {:ok, new_data}
  #         done? -> {:error, {new_status, new_data}}
  #         !done? -> receive_resp(conn, ref, new_status, new_data, done?)
  #       end
  #   end
  # end
end

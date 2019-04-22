# The Endpoint and Router are just fancy names. The real difference is Endpoint module is a child of a Supervised Application. For example, this "Router" directly serves requests.

defmodule MinimalServer.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(message()))
  end

  defp message do
    %{
      time: DateTime.utc_now(),
      response_type: "in_channel",
      text: "Hello world"
    }
  end
end

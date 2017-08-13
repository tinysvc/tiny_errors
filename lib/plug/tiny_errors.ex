defmodule Plug.TinyErrors do
  import Plug.Conn

  @moduledoc """
  Plug for outputing errors as a json feed.
  Make sure to secure the route somehow!
  """

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    send_json(conn)
  end

  defp send_json(conn) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, build_json())
    |> halt
  end

  defp build_json do
    TinyErrors.list |> Poison.encode!
  end
end

defmodule TinyErrors.LoggerBackend do
  require Logger
  use GenEvent

  def init(_mod, []), do: {:ok, []}

  def handle_call({:configure, config}, _state), do: {:ok, :ok, config}

  def handle_event({_level, gl, _event}, state) when node(gl) != node() do
    {:ok, state}
  end
	def handle_event({:error, _gl, {Logger, msg, ts, md}}, state) do
		{:ok, report_error(msg, ts, md)}
	end
  def handle_event(_, state), do: {:ok, state}

  defp report_error(msg, ts, md) do
    TinyErrors.Reporter.report(msg, ts, md)
  end
end


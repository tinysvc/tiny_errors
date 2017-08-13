defmodule TinyErrors.Reporter do
  use GenServer

	def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init(_) do
    error_limit = Application.get_env(:tiny_errors, :error_limit, 50)
    {:ok, [errors: [], error_limit: error_limit]}
  end

  def report(msg, ts, md, pid \\ __MODULE__) do
    msg = to_string(msg)
    key = unique_key(msg)
    report = %{key: key, msg: msg, ts: ts, md: md}
    GenServer.cast(pid, {:error, report})
  end

  def list(pid \\ __MODULE__) do
    GenServer.call(pid, :list)
  end

  def handle_cast({:error, report}, state) do
    state = append_report(state, report)
    {:noreply, state}
  end

  def handle_call(:list, _from, state) do
    errors = state[:errors]
    |> Enum.map(fn(error) ->
      Map.merge(error, %{
        ts: tuple_to_iso8601(error.ts),
        first_seen: tuple_to_iso8601(error.first_seen),
        last_seen: tuple_to_iso8601(error.last_seen),
        md: json_friendly_md(error.md)
      })
    end)
    {:reply, errors, state}
  end

  def unique_key(msg) do
    pid_pattern = ~r/#PID<[0-9]*\.[0-9]*\.[0-9]*>/
    deduped_msg = Regex.replace(pid_pattern, msg, "") |> String.trim
    :crypto.hmac(:sha256, "key", deduped_msg) |> Base.encode16
  end

  defp append_report(state, report) do
    errors = state[:errors]
    current_report = Enum.find(errors, fn(%{key: key}) -> key == report.key end) || %{
        occurrence_count: 0,
        first_seen: report.ts
      }
    new_count = current_report.occurrence_count + 1

    new_report = current_report
    |> Map.merge(report)
    |> Map.put(:occurrence_count, new_count)
    |> Map.put(:last_seen, report.ts)

    new_errors = errors
    |> Enum.reject(fn(error) -> error.key == report.key end)
    |> List.insert_at(0, new_report)
    |> Enum.sort_by(fn(error) -> error.last_seen end)
    |> Enum.reverse
    |> truncate_to_limit(state[:error_limit])

    Keyword.put(state, :errors, new_errors)
  end

  defp truncate_to_limit(errors, limit) do
    if Enum.count(errors) <= limit do
      errors
    else
      [_ | errors] = errors
      truncate_to_limit(errors, limit)
    end
  end

  defp tuple_to_iso8601({date_tuple, {h, m, s, _}}) do
    n = NaiveDateTime.from_erl!({date_tuple, {h, m, s}})
    NaiveDateTime.to_iso8601(n)
  end

  defp json_friendly_md(md) do
    md
    |> Enum.map(fn({k, v}) ->
      {inspect(k), inspect(v)}
    end)
    |> Enum.into(%{})
  end
end


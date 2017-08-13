defmodule TinyErrors.ReporterTest do
  use ExUnit.Case
  alias TinyErrors.Reporter

  test "de-dupes messages with same message but different pids" do
    test_message1 = "#PID<0.690.0> some kind of error"
    test_message2 = "#PID<0.999.0> some kind of error"
    ts = {{2017, 7, 30}, {15, 27, 36, 40}}
    md = []
    {:ok, pid} = Reporter.start_link
    Reporter.report(test_message1, ts, md, pid)
    Reporter.report(test_message2, ts, md, pid)
    errors = Reporter.list(pid)
    assert errors |> Enum.count == 1
  end

  test "keeps occurrence count" do
    test_message1 = "#PID<0.690.0> some kind of error"
    test_message2 = "#PID<0.999.0> some kind of error"
    ts = {{2017, 7, 30}, {15, 27, 36, 40}}
    md = []
    {:ok, pid} = Reporter.start_link
    Reporter.report(test_message1, ts, md, pid)
    [error | _] = Reporter.list(pid)
    assert error.occurrence_count == 1

    Reporter.report(test_message2, ts, md, pid)
    [error | _] = Reporter.list(pid)
    assert error.occurrence_count == 2
  end

  test "updates last seen timestamp" do
    test_message1 = "#PID<0.690.0> some kind of error"
    test_message2 = "#PID<0.999.0> some kind of error"
    ts1 = {{2017, 7, 30}, {15, 27, 36, 40}}
    ts2 = {{2017, 7, 31}, {15, 27, 36, 40}}
    md = []
    {:ok, pid} = Reporter.start_link
    Reporter.report(test_message1, ts1, md, pid)
    Reporter.report(test_message2, ts2, md, pid)
    [error | _] = Reporter.list(pid)
    assert error.last_seen == tuple_to_iso8601(ts2)
  end

  test "keeps a first seen timestamp" do
    test_message1 = "#PID<0.690.0> some kind of error"
    test_message2 = "#PID<0.999.0> some kind of error"
    ts1 = {{2017, 7, 30}, {15, 27, 36, 40}}
    ts2 = {{2017, 7, 31}, {15, 27, 36, 40}}
    md = []
    {:ok, pid} = Reporter.start_link
    Reporter.report(test_message1, ts1, md, pid)
    Reporter.report(test_message2, ts2, md, pid)
    [error | _] = Reporter.list(pid)
    assert error.first_seen == tuple_to_iso8601(ts1)
  end

  test "truncates oldest error after reaching configured limit" do
    {:ok, pid} = Reporter.start_link
    error_limit = Application.get_env(:tiny_errors, :error_limit)
    1..error_limit |> Enum.each(fn(n) ->
      test_message = "#PID<0.690.#{n}> unique error #{n}"
      ts = {{2017, 7, 30}, {15, 27, 36, n}}
      Reporter.report(test_message, ts, [], pid)
    end)
    test_message = "#PID<0.690.0> another error"
    ts = {{2017, 7, 30}, {15, 27, 36, 40}}
    Reporter.report(test_message, ts, [], pid)
    errors = Reporter.list(pid)
    assert Enum.count(errors) == error_limit
  end

  test "returns a json serializable list" do
    {:ok, pid} = Reporter.start_link
    md = [{:error_logger, :format}]
    test_message = "#PID<0.690.0> any error"
    ts = {{2017, 7, 30}, {15, 27, 36, 1}}
    Reporter.report(test_message, ts, md, pid)
    errors = Reporter.list(pid)
    assert Poison.encode!(errors)
  end

  defp tuple_to_iso8601({date_tuple, {h, m, s, _}}) do
    n = NaiveDateTime.from_erl!({date_tuple, {h, m, s}})
    NaiveDateTime.to_iso8601(n)
  end
end

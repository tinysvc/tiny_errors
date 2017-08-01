# TinyErrors

This package keeps a simple in-memory dataset of recent error activity in Elixir applications.
You can use this data to build a little dashboard or JSON feed, whatever you want.
There are no external dependencies so if you don't want to fork over cash for a hosted solution,
and you simply want to know what your most recent errors are... this package might be all you need.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `tiny_errors` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:tiny_errors, "~> 0.1.0"}]
end
```

Configure how many errors you want to keep in memory.  Repeated instances of the same error do not count toward this total.  The least recently seen errors will be dropped off the list when the limit is reached.

```elixir
# config.exs
config :tiny_errors, error_limit: 50 # defaults to 50
```

Add the logger backend to your logger.

```elixir
# config.exs
config :logger, backends: [:console, TinyErrors.LoggerBackend]
```

## Usage

Get the list of reported errors at any time with this function:
```
TinyErrors.list
```

## Current Known Limitations

This package isn't intended to be the end-all-be-all solution for error tracking. However, we can
certainly consider adding helpful features.  Just file an issue, or open a PR.

- Error data is not persistent (won't survive restarts)
    - Should we add a way to periodically persist to a flat file?
- Data is only per node so results are not aggregated from a cluster or from multiple running servers.


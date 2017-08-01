defmodule TinyErrors do
  use Application
  import Supervisor.Spec

  def start(_type, _args) do
    children = [
      worker(TinyErrors.Reporter, [[name: TinyErrors.Reporter]]),
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def list do
    TinyErrors.Reporter.list
  end
end

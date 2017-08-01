defmodule TinyErrors.Mixfile do
  use Mix.Project
  @version "0.1.0"

  def project do
    [app: :tiny_errors,
     version: @version,
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     docs: [
       extras: ["README.md"],
       main: "readme",
       source_ref: "v#{@version}",
       source_url: "https://github.com/tinysvc/tiny_errors",
     ],
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [
      extra_applications: [:logger],
      mod: {TinyErrors, []}
    ]
  end

  defp description do
    """
    A tiny library for looking at recent errors in an Elixir application
    """
  end

  defp package do
    [# These are the default files included in the package
     name: :tiny_errors,
     files: ["lib", "mix.exs", "README*", "LICENSE*"],
     maintainers: ["Brandon Joyce"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/tinysvc/tiny_errors",
      "Docs" => "https://github.com/tinysvc/tiny_errors"}]
  end

  defp deps do
    []
  end
end

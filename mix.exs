defmodule Cartel.Mixfile do
  use Mix.Project

  def project do
    [app: :cartel,
     version: "0.0.2",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :ssl, :poolboy, :poison, :httpotion, :chatterbox],
     mod: {Cartel, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:credo, "~> 0.3", only: [:dev, :test]},
      {:poison, "~> 2.1.0"},
      {:httpotion, "~> 2.2.0"},
      {:poolboy, "~> 1.5.1"},
      {:chatterbox, github: "joedevivo/chatterbox", branch: :master}
    ]
  end
end

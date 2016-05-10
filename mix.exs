defmodule Cartel.Mixfile do
  use Mix.Project

  def project do
    [app: :cartel,
     version: "0.1.0",
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
      {:ex_doc, ">= 0.0.0", only: [:dev]},
      {:earmark, ">= 0.0.0", only: [:dev]},
      {:credo, "~> 0.3", only: [:dev]},
      {:poison, "~> 2.1.0"},
      {:httpotion, "~> 2.2.0"},
      {:poolboy, "~> 1.5.1"},
      {:chatterbox, github: "joedevivo/chatterbox", branch: :master}
    ]
  end
end

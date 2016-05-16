defmodule Cartel.Mixfile do
  use Mix.Project

  def project do
    [app: :cartel,
     version: "0.2.2",
     elixir: "~> 1.2",
     description: "Multi platform, multi app push notifications",
     package: package,
     docs: docs,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger, :ssl, :poolboy, :poison, :httpotion, :chatterbox],
     mod: {Cartel, []}]
  end

  defp package do
    [
      maintainers: ["Luca Corti"],
      licenses: ["MIT"],
      links: %{ "GitHub": "https://github.com/lucacorti/cartel" }
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: [:dev]},
      {:earmark, ">= 0.0.0", only: [:dev]},
      {:credo, "~> 0.3", only: [:dev]},
      {:dialyxir, "~> 0.3.3", only: [:dev]},
      {:poison, "~> 2.1.0"},
      {:httpotion, "~> 2.2.0"},
      {:poolboy, "~> 1.5.1"},
      {:chatterbox, "~> 0.3.0", manager: :rebar, github: "joedevivo/chatterbox", tag: "0.3.0"}
    ]
  end

  defp docs do
    [
      main: "main",
      extras: ["docs/main.md", "docs/getting-started.md", "docs/usage.md"]
    ]
  end
end

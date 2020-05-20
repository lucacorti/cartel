defmodule Cartel.Mixfile do
  use Mix.Project

  def project do
    [
      app: :cartel,
      version: "0.7.0",
      elixir: "~> 1.5",
      description: "Multi platform, multi app push notifications",
      package: package(),
      docs: docs(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [extra_applications: [:logger], mod: {Cartel, []}]
  end

  defp package do
    [
      maintainers: ["Luca Corti"],
      licenses: ["MIT"],
      links: %{GitHub: "https://github.com/lucacorti/cartel"}
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: [:dev]},
      {:earmark, ">= 0.0.0", only: [:dev]},
      {:credo, "~> 1.1", only: [:dev]},
      {:dialyxir, "~> 0.5.0", only: [:dev]},
      {:jason, "~> 1.2.0"},
      {:mint, "~> 1.1.0"},
      {:castore, ">= 0.0.0"},
      {:poolboy, "~> 1.5.1"}
    ]
  end

  defp docs do
    [
      main: "main",
      extras: [
        "docs/main.md",
        "docs/getting-started.md",
        "docs/usage.md"
        # "docs/extending.md"
      ]
    ]
  end
end

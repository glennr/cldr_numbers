defmodule CldrNumbers.Mixfile do
  @moduledoc false

  use Mix.Project

  @version "2.4.1"

  def project do
    [
      app: :ex_cldr_numbers,
      version: @version,
      elixir: "~> 1.5",
      name: "Cldr Numbers",
      description: description(),
      source_url: "https://github.com/kipcole9/cldr_numbers",
      docs: docs(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      package: package(),
      dialyzer: [
        ignore_warnings: ".dialyzer_ignore_warnings",
        plt_add_apps: ~w(gettext inets jason mix plug)a
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    """
    Number and currency localization and formatting functions for the Common Locale Data Repository (CLDR).
    """
  end

  defp deps do
    [
      {:ex_cldr, "~> 2.1"},
      {:ex_cldr_currencies, "~> 2.2"},
      {:decimal, "~> 1.5"},
      {:jason, "~> 1.0", optional: true},
      {:ex_doc, "~> 0.18", only: [:dev, :release], optional: true},
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Kip Cole"],
      licenses: ["Apache 2.0"],
      links: links(),
      files: [
        "lib",
        "src/decimal_formats_lexer.xrl",
        "src/decimal_formats_parser.yrl",
        "src/rbnf_lexer.xrl",
        "src/rbnf_parser.yrl",
        "config",
        "mix.exs",
        "README*",
        "CHANGELOG*",
        "LICENSE*"
      ]
    ]
  end

  def docs do
    [
      source_ref: "v#{@version}",
      main: "readme",
      extras: ["README.md", "CHANGELOG.md", "LICENSE.md"],
      logo: "logo.png"
    ]
  end

  def links do
    %{
      "GitHub" => "https://github.com/kipcole9/cldr_numbers",
      "Readme" => "https://github.com/kipcole9/cldr_numbers/blob/v#{@version}/README.md",
      "Changelog" => "https://github.com/kipcole9/cldr_numbers/blob/v#{@version}/CHANGELOG.md"
    }
  end

  defp elixirc_paths(:test), do: ["lib", "test", "mix"]
  defp elixirc_paths(:dev), do: ["lib", "mix"]
  defp elixirc_paths(_), do: ["lib"]
end

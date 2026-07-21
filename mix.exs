defmodule RextNew.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/genericjam/rext_new"

  def project do
    [
      app: :rext_new,
      version: @version,
      elixir: "~> 1.20",
      deps: deps(),
      aliases: aliases(),
      description: "Project generator for rext desktop apps (`mix rext.new`).",
      package: package(),
      docs: docs(),
      source_url: @source_url
    ]
  end

  def application, do: [extra_applications: [:logger]]

  defp deps do
    [
      {:ex_doc, "~> 0.40", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:jump_credo_checks, "~> 0.4", only: [:dev, :test], runtime: false},
      {:ex_slop, "~> 0.4", only: [:dev, :test], runtime: false},
      {:mix_audit, "~> 2.1", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [setup: ["deps.get", "cmd git config core.hooksPath .githooks"]]
  end

  defp package do
    [licenses: ["MIT"], links: %{"GitHub" => @source_url}]
  end

  defp docs do
    [main: "readme", extras: ["README.md"]]
  end
end

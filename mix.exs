defmodule CloudStorage.Mixfile do
  use Mix.Project

  def project do
    [
      app: :cloud_storage,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 0.13.0"},
      {:elixir_xml_to_map, "~> 0.1.1"},
      {:mime, "~> 1.1"},
      {:poison, "~> 3.1"},
    ]
  end
end

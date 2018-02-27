defmodule CloudStorage.Mixfile do
  use Mix.Project

  def project do
    [
      app: :cloud_storage,
      version: "0.3.1",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "Cloud Storage",
      source_url: "https://github.com/pedromvieira/cloud_storage"
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    """
    Elixir package to interact via REST API with Azure Storage and CDN Endpoint.
    """
  end

  defp package do
    [
      name: :cloud_storage,
      files: ["lib", "mix.exs", "LICENSE", "README.md"],
      maintainers: ["Pedro Vieira - pedro@vieira.net"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/pedromvieira/cloud_storage"}
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 0.13.0"},
      {:elixir_xml_to_map, "~> 0.1.1"},
      {:mime, "~> 1.1"},
      {:poison, "~> 3.1"},
      {:ex_doc, "~> 0.16.2", only: :dev, runtime: false},
    ]
  end
end

defmodule QuickXml.MixProject do
  use Mix.Project

  @source_url "https://github.com/faelgabriel/quick_xml"
  @version "0.1.0"
  @description "NIF library for parsing XML into Elixir maps using quick-xml Rust crate."

  def project do
    [
      app: :quick_xml,
      version: @version,
      elixir: "~> 1.11",
      description: @description,
      start_permanent: Mix.env() == :prod,
      package: package(),
      docs: docs(),
      deps: deps()
    ]
  end

  defp package do
    [
      maintainers: ["Rafael Gabriel"],
      licenses: ["MIT"],
      links: %{
        GitHub: @source_url,
        "quick-xml": "https://crates.io/crates/quick-xml"
      },
      files: [
        "lib",
        "native",
        "checksum-*.exs",
        "mix.exs",
        "LICENSE",
        "README.md",
        "CHANGELOG.md"
      ]
    ]
  end

  defp docs do
    [
      main: "QuickXml",
      source_ref: "v#{@version}",
      source_url: @source_url,
      extras: ["CHANGELOG.md"]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.37", only: :dev, runtime: false},
      {:rustler, "~> 0.36", runtime: false}
    ]
  end
end

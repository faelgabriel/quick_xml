defmodule QuickXml.MixProject do
  use Mix.Project

  @source_url "https://github.com/faelgabriel/quick_xml"
  @version "0.1.0"

  def project do
    [
      app: :quick_xml,
      version: @version,
      elixir: "~> 1.13",
      description:
        "An XML parsing library for Elixir using a Rust NIF powered by the quick-xml crate.",
      start_permanent: Mix.env() == :prod,
      package: package(),
      docs: docs(),
      deps: deps(),
      aliases: aliases()
    ]
  end

  defp package do
    [
      maintainers: ["Rafael Gabriel"],
      licenses: ["MIT"],
      links: %{
        GitHub: @source_url,
        HexDocs: "https://hexdocs.pm/quick_xml",
        "Crate (quick-xml)": "https://crates.io/crates/quick-xml"
      },
      files: [
        "lib",
        "native",
        "checksum-*.exs",
        "mix.exs",
        "LICENSE",
        "README.md",
        "CHANGELOG.md"
      ],
      categories: ["Parsing", "NIF", "XML"]
    ]
  end

  defp docs do
    [
      main: "QuickXml",
      extras: [
        "CHANGELOG.md": [],
        LICENSE: [title: "License"],
        "README.md": [title: "Overview"]
      ],
      source_ref: "v#{@version}",
      source_url: @source_url,
      homepage_url: @source_url,
      formatters: ["html"]
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
      {:rustler, ">= 0.0.0", optional: true},
      {:rustler_precompiled, "~> 0.8"}
    ]
  end

  defp aliases do
    [
      # always force building the NIF for test runs:
      test: [fn _ -> System.put_env("QUICK_XML_NIF_BUILD", "true") end, "test"]
    ]
  end
end

defmodule QuickXml do
  @moduledoc """
  QuickXml is an XML parsing library for Elixir using a Rust NIF powered by the quick-xml crate.
  """

  env_config = Application.compile_env(:rustler_precompiled, :force_build, [])
  version = Mix.Project.config()[:version]

  use RustlerPrecompiled,
    otp_app: :quick_xml,
    crate: "quick_xml_nif",
    base_url: "https://github.com/faelgabriel/quick_xml/releases/download/v#{version}",
    force_build:
      System.get_env("QUICK_XML_NIF_BUILD") in ["1", "true"] or env_config[:quick_xml] == true,
    targets:
      Enum.uniq(
        ["aarch64-unknown-linux-musl", "x86_64-unknown-freebsd"] ++
          RustlerPrecompiled.Config.default_targets()
      ),
    version: version,
    nif_versions: ["2.15", "2.16"]

  @type parse_error_type :: :invalid_xml | :unexpected_eof | :malformed_xml | :unknown_error

  @doc """
  Parses an XML string into an Elixir map.

  ## Parameters

    - `xml` (string): The XML content to be parsed.

  ## Returns

    - `{:ok, map}` – If the XML is successfully parsed.
    - `{:error, {error_type, message}}` – If parsing fails.

  ## Error Types

  - `:invalid_xml` – The XML structure is incorrect or incomplete.
  - `:unexpected_eof` – The document ends unexpectedly.
  - `:malformed_xml` – The XML contains structural issues.
  - `:unknown_error` – An unspecified error occurred during parsing.

  ## Examples

      iex> QuickXml.parse("<root><name>John</name></root>")
      {:ok, %{"name" => %{"$text" => "John"}}}

      iex> QuickXml.parse("<unclosed>")
      {:error, {:malformed_xml, "ill-formed document: start tag not closed: `</unclosed>` not found before end of input"}}

      iex> QuickXml.parse("")
      {:error, {:unexpected_eof, "no details"}}
  """
  @spec parse(String.t()) :: {:ok, map()} | {:error, {parse_error_type(), String.t()}}
  def parse(_xml), do: :erlang.nif_error(:nif_not_loaded)

  @doc """
  Same as `parse/1`, but returns the parsed map directly or raises an exception if parsing fails.
  """
  @spec parse!(String.t()) :: map()
  def parse!(xml) do
    case parse(xml) do
      {:ok, result} -> result
      {:error, {error_type, message}} -> raise RuntimeError, "#{error_type}: #{message}"
    end
  end
end

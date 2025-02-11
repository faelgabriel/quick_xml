defmodule QuickXml do
  @moduledoc """
  QuickXml is a NIF library for parsing XML into Elixir maps using quick-xml Rust crate.
  """

  use Rustler,
    otp_app: :quick_xml,
    crate: "quick_xml_nif"

  @type parse_error_type :: :invalid_xml | :unexpected_eof | :malformed_xml | :unknown_error

  @doc """
  Parses an XML string into an Elixir map.
  """
  @spec parse(String.t()) :: {:ok, map()} | {:error, {parse_error_type(), String.t()}}
  def parse(_xml), do: :erlang.nif_error(:nif_not_loaded)
end

# QuickXml

[![CI](https://github.com/faelgabriel/quick_xml/actions/workflows/ci.yml/badge.svg)](https://github.com/faelgabriel/quick_xml/actions/workflows/ci.yml)

QuickXml is a NIF library for parsing XML in Elixir using the [`quick-xml`](https://crates.io/crates/quick-xml) Rust crate. It provides a fast and efficient way to convert XML strings into Elixir maps.

## Installation

Add `quick_xml` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:quick_xml, "~> 0.1.0"}
  ]
end
```

### Requirements

Since **precompiled binaries are not available**, you need **Rust installed** on your system to compile the NIF. Install Rust using [Rustup](https://rust-lang.github.io/rustup/installation/index.html).

## Usage

To parse an XML string into an Elixir map, use `QuickXml.parse/1`:

```elixir
xml = "<root><name>John</name><age>30</age></root>"
{:ok, parsed_map} = QuickXml.parse(xml)

# Expected output:
{:ok, %{"age" => %{"$text" => "30"}, "name" => %{"$text" => "John"}}}
```

If the XML is invalid, it returns an error tuple:

```elixir
{:error, {:invalid_xml, "syntax error: xml must have a node"}}
```

## Benchmarking

It includes a benchmarking script (`benchmark.exs`) that generates mock XML content to measure parsing performance. You can run it with:

```sh
elixir benchmark.exs --kb 100
```

Where `--kb` defines the size of the generated XML content in kilobytes.

## License

QuickXml is released under the [MIT License](./LICENSE).

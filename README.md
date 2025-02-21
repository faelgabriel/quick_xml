# QuickXml

[![CI](https://github.com/faelgabriel/quick_xml/actions/workflows/ci.yml/badge.svg)](https://github.com/faelgabriel/quick_xml/actions/workflows/ci.yml)

QuickXml is an XML parsing library for Elixir using a Rust NIF powered by the [`quick-xml`](https://crates.io/crates/quick-xml) crate. It provides a fast and efficient way to convert XML strings into Elixir maps.

## Installation

Add `quick_xml` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:quick_xml, "~> 0.1"}
  ]
end
```

### Force Compilation

This library includes pre-compiled binaries for the native Rust code. If you
want to force-compile the Rust code, you can add the following configuration
to your application:

```elixir
config :rustler_precompiled, :force_build, quick_xml: true
```

You also need to add Rustler to your dependencies:

```elixir
def deps do
  [
    {:quick_xml, "~> 0.1.0"},
    {:rustler, ">= 0.0.0", optional: true}
  ]
end
```

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
elixir benchmark.exs
```

For custom XML content size in kilobytes, you can pass the `--kb` flag with the desired size. For example: `elixir benchmark.exs --kb 100`.

## Sample Benchmark Results

<details>
  <summary>Click to expand</summary>

```
Operating System: Linux
CPU Information: AMD Ryzen 5 5600GT with Radeon Graphics
Number of Available Cores: 12
Available memory: 15.52 GB
Elixir 1.18.2
Erlang 27.2.2
JIT enabled: true

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 5 s
memory time: 0 ns
reduction time: 0 ns
parallel: 4
inputs: 1500 KB, 300 KB, 3000 KB, 50 KB
Estimated total run time: 1 min 52 s
```

```
##### With input 50 KB #####
Name                           ips        average  deviation         median         99th %
QuickXml.parse/1           2162.20        0.46 ms    ±25.26%        0.40 ms        0.77 ms
SAXMap.from_string/1        918.36        1.09 ms    ±26.53%        0.97 ms        1.90 ms
:xmerl_scan.string/1        199.95        5.00 ms    ±27.94%        4.83 ms        8.77 ms
SweetXml.xpath/2            131.20        7.62 ms    ±22.81%        7.43 ms       13.13 ms

Comparison: 
QuickXml.parse/1           2162.20
SAXMap.from_string/1        918.36 - 2.35x slower +0.63 ms
:xmerl_scan.string/1        199.95 - 10.81x slower +4.54 ms
SweetXml.xpath/2            131.20 - 16.48x slower +7.16 ms
```

```
##### With input 300 KB #####
Name                           ips        average  deviation         median         99th %
QuickXml.parse/1            418.74        2.39 ms    ±94.70%        2.12 ms        3.49 ms
SAXMap.from_string/1        158.07        6.33 ms    ±24.90%        5.91 ms       11.32 ms
:xmerl_scan.string/1         21.73       46.01 ms    ±16.88%       47.00 ms       63.06 ms
SweetXml.xpath/2             15.48       64.59 ms    ±12.66%       62.93 ms       82.58 ms

Comparison: 
QuickXml.parse/1            418.74
SAXMap.from_string/1        158.07 - 2.65x slower +3.94 ms
:xmerl_scan.string/1         21.73 - 19.27x slower +43.62 ms
SweetXml.xpath/2             15.48 - 27.05x slower +62.20 ms
```

```
##### With input 1500 KB #####
Name                           ips        average  deviation         median         99th %
QuickXml.parse/1             66.33       0.0151 s   ±410.35%       0.0104 s       0.0165 s
SAXMap.from_string/1         11.78       0.0849 s     ±5.84%       0.0841 s        0.105 s
:xmerl_scan.string/1          0.78         1.29 s     ±2.24%         1.28 s         1.34 s
SweetXml.xpath/2              0.67         1.49 s     ±4.33%         1.51 s         1.59 s

Comparison: 
QuickXml.parse/1             66.33
SAXMap.from_string/1         11.78 - 5.63x slower +0.0698 s
:xmerl_scan.string/1          0.78 - 85.48x slower +1.27 s
SweetXml.xpath/2              0.67 - 98.75x slower +1.47 s
```

```
##### With input 3000 KB #####
Name                           ips        average  deviation         median         99th %
QuickXml.parse/1             30.64       0.0326 s   ±469.51%       0.0214 s       0.0399 s
SAXMap.from_string/1          5.86        0.171 s     ±4.43%        0.170 s        0.196 s
:xmerl_scan.string/1          0.34         2.97 s     ±3.32%         2.97 s         3.09 s
SweetXml.xpath/2              0.29         3.41 s     ±1.99%         3.38 s         3.53 s

Comparison: 
QuickXml.parse/1             30.64
SAXMap.from_string/1          5.86 - 5.23x slower +0.138 s
:xmerl_scan.string/1          0.34 - 90.96x slower +2.94 s
SweetXml.xpath/2              0.29 - 104.44x slower +3.38 s
```
</details>


## License

QuickXml is released under the [MIT License](./LICENSE).

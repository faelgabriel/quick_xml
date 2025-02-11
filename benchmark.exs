Mix.install([
  {:benchee, "~> 1.3"},
  {:elixir_xml_to_map, "~> 3.1"},
  {:sax_map, "~> 1.4"},
  {:sweet_xml, "~> 0.7"}
])

# QuickXml
Code.prepend_path("_build/dev/lib/quick_xml/ebin")

defmodule XMLGenerator do
  def generate_xml(kb) when is_integer(kb) and kb > 0 do
    bytes = kb * 1024

    header = "<library><section><category><sub-category><collection><books>"
    footer = "</books></collection></sub-category></category></section></library>"

    book_block = """
    <book>
      <metadata>
        <title>Title</title>
        <author>
          <name>
            <first>First</first>
            <last>Last</last>
          </name>
        </author>
        <genre>
          <type>
            <category>Fiction</category>
          </type>
        </genre>
        <year>
          <published>
            <date>2020</date>
          </published>
        </year>
        <publisher>
          <info>
            <website>http://example.com</website>
          </info>
        </publisher>
      </metadata>
    </book>
    """

    book_block = String.trim(book_block)

    header_size = byte_size(header)
    footer_size = byte_size(footer)
    book_size = byte_size(book_block)

    needed = bytes - header_size - footer_size
    count = div(needed, book_size) + if rem(needed, book_size) > 0, do: 1, else: 0

    body = String.duplicate(book_block, count)
    header <> body <> footer
  end
end

defmodule SweetXmlParser do
  import SweetXml

  def parse(xml) do
    xml
    |> xpath(
      ~x"//library"e,
      section: [
        ~x"./section"e,
        category: [
          ~x"./category"e,
          sub_category: [
            ~x"./sub-category"e,
            collection: [
              ~x"./collection"e,
              books: [
                ~x"./books"e,
                book: [
                  ~x"./book"e,
                  metadata: [
                    ~x"./metadata"e,
                    title: ~x"./title/text/text()"s,
                    author: [
                      ~x"./author"e,
                      name: [
                        ~x"./name"e,
                        first: ~x"./first/text()"s,
                        last: ~x"./last/text()"s
                      ]
                    ],
                    genre: [
                      ~x"./genre"e,
                      type: [
                        ~x"./type"e,
                        category: ~x"./category/text()"s
                      ]
                    ],
                    year: [
                      ~x"./year"e,
                      published: [
                        ~x"./published"e,
                        date: ~x"./date/text()"s
                      ]
                    ],
                    publisher: [
                      ~x"./publisher"e,
                      info: [
                        ~x"./info"e,
                        website: ~x"./website/text()"s
                      ]
                    ]
                  ]
                ]
              ]
            ]
          ]
        ]
      ]
    )
  end
end

defmodule SAXMapParser do
  def parse(xml) do
    case SAXMap.from_string(xml) do
      {:ok, map} -> map
      _ -> :error
    end
  end
end

defmodule XmlToMapParser do
  def parse(xml) do
    case XmlToMap.naive_map(xml) do
      {:ok, map} -> map
      _ -> :error
    end
  end
end

defmodule XmerlParser do
  def parse(xml) do
    case :xmerl_scan.string(String.to_charlist(xml)) do
      {:error, _} -> :error
      {parsed, _rest} -> parsed
    end
  end
end

{opts, _argv, _errors} = OptionParser.parse(System.argv(), switches: [kb: :integer])

size_kb = Keyword.get(opts, :kb, 100)
xml = XMLGenerator.generate_xml(size_kb)

IO.puts("🔥 Generated XML content of #{byte_size(xml)} bytes (~#{size_kb} KB requested)")

Benchee.run(
  %{
    "QuickXml.parse/1" => fn -> QuickXml.parse(xml) end,
    "SweetXmlParser.parse/1" => fn -> SweetXmlParser.parse(xml) end,
    "SAXMapParser.parse/1" => fn -> SAXMapParser.parse(xml) end,
    "XmlToMapParser.parse/1" => fn -> XmlToMapParser.parse(xml) end,
    "XmerlParser.parse/1" => fn -> XmerlParser.parse(xml) end
  },
  time: 5,
  warmup: 2,
  parallel: 1
)

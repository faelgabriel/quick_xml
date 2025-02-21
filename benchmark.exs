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

    header = """
    <?xml version="1.0" encoding="UTF-8"?>
    <response action="searchProducts" requestId="987654321" source="192.168.1.100" timestamp="2023-12-15 15:30:45" apiVersion="2.1" processingTime="0.8543210">
      <baseCurrency>EUR</baseCurrency>
      <markup>10</markup>
      <store id="123456" title="ACME Electronics Store">
        <status>active</status>
        <products total="1">
    """

    footer = """
        </products>
      </store>
      <status>SUCCESS</status>
    </response>
    """

    product_block = """
          <product sequence="0" stock="50" minQuantity="1" maxQuantity="5" warrantyMonths="24">
            <category sequence="0" categoryId="987654">
              <title>Premium Gaming Laptop</title>
              <availability>inStock</availability>
              <specifications>
                <screen>17.3</screen>
                <processor>5.2GHz</processor>
                <memory>32GB</memory>
                <storage>2TB</storage>
                <graphics>12GB GDDR6</graphics>
              </specifications>
              <variants total="2">
                <variant sequence="0" sku="LP789" label="Performance">
                  <condition>new</condition>
                  <shippingDetails required="1">
                    <method type="express" region="EU" estimatedDays="3">priority</method>
                  </shippingDetails>
                  <policyRules total="2">
                    <policy sequence="0">
                      <validFrom>2023-12-10 00:00:01</validFrom>
                      <validUntil>2023-12-25 23:59:59</validUntil>
                      <refundAmount>
                        1899.99
                        <display>1,899.99</display>
                      </refundAmount>
                      <restockingFee>
                        189.99
                        <display>189.99</display>
                      </restockingFee>
                    </policy>
                    <policy sequence="1">
                      <validFrom>2023-12-26 00:00:01</validFrom>
                      <nonRefundable>true</nonRefundable>
                    </policy>
                  </policyRules>
                  <pricing>
                    1899.99
                    <display>1,899.99</display>
                  </pricing>
                  <availability>
                    <regions total="3">
                      <region sequence="0" code="FR" name="France">
                        <price>
                          1899.99
                          <display>1,899.99</display>
                        </price>
                        <deliveryTime>48h</deliveryTime>
                        <extras total="1">
                          <service sequence="0">
                            <name>Extended Warranty</name>
                            <duration code="EW12">12 Months</duration>
                          </service>
                        </extras>
                      </region>
                      <region sequence="1" code="DE" name="Germany">
                        <price>
                          1899.99
                          <display>1,899.99</display>
                        </price>
                        <deliveryTime>72h</deliveryTime>
                        <extras total="1">
                          <service sequence="0">
                            <name>Extended Warranty</name>
                            <duration code="EW12">12 Months</duration>
                          </service>
                        </extras>
                      </region>
                    </regions>
                  </availability>
                </variant>
              </variants>
            </category>
          </product>
    """

    header = String.trim(header)
    footer = String.trim(footer)
    product_block = String.trim(product_block)

    header_size = byte_size(header)
    footer_size = byte_size(footer)
    product_size = byte_size(product_block)

    needed = bytes - header_size - footer_size
    count = div(needed, product_size) + if rem(needed, product_size) > 0, do: 1, else: 0

    body = String.duplicate(product_block, count)
    header <> body <> footer
  end
end

defmodule SweetXmlParser do
  import SweetXml

  def parse(xml) do
    xml
    |> xpath(
      ~x"//response"e,
      action: ~x"./@action"s,
      requestId: ~x"./@requestId"s,
      baseCurrency: ~x"./baseCurrency/text()"s,
      markup: ~x"./markup/text()"s,
      store: [
        ~x"./store"e,
        id: ~x"./@id"s,
        title: ~x"./@title"s,
        status: ~x"./status/text()"s,
        products: [
          ~x"./products"e,
          total: ~x"./@total"s,
          product: [
            ~x"./product"l,
            sequence: ~x"./@sequence"s,
            stock: ~x"./@stock"s,
            category: [
              ~x"./category"e,
              title: ~x"./title/text()"s,
              variants: [
                ~x"./variants"e,
                variant: [
                  ~x"./variant"l,
                  condition: ~x"./condition/text()"s,
                  pricing: ~x"./pricing/display/text()"s
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
      error -> raise "Error parsing XML: #{inspect(error)}"
    end
  end
end

defmodule XmlToMapParser do
  def parse(xml) do
    XmlToMap.naive_map(xml)
  end
end

defmodule XmerlScanParser do
  def parse(xml) do
    case :xmerl_scan.string(String.to_charlist(xml)) do
      {:error, _} = error -> raise "Error parsing XML: #{inspect(error)}"
      {parsed, _rest} -> parsed
    end
  end
end

defmodule QuickXmlParser do
  def parse(xml) do
    case QuickXml.parse(xml) do
      {:ok, map} -> map
      error -> raise "Error parsing XML: #{inspect(error)}"
    end
  end
end

{opts, _argv, _errors} = OptionParser.parse(System.argv(), switches: [kb: :integer])

xml_inputs =
  case Keyword.get(opts, :kb) do
    nil ->
      %{
        "50 KB" => XMLGenerator.generate_xml(50),
        "300 KB" => XMLGenerator.generate_xml(300),
        "1500 KB" => XMLGenerator.generate_xml(1500),
        "3000 KB" => XMLGenerator.generate_xml(3000)
      }

    size_kb when is_integer(size_kb) ->
      %{"#{size_kb} KB" => XMLGenerator.generate_xml(size_kb)}
  end

Enum.each(xml_inputs, fn {label, xml} ->
  IO.puts("Prepared XML input for #{label} (#{byte_size(xml)} bytes)")
end)

Benchee.run(
  %{
    "QuickXml.parse/1" => fn xml -> QuickXmlParser.parse(xml) end,
    "SweetXml.xpath/2" => fn xml -> SweetXmlParser.parse(xml) end,
    "SAXMap.from_string/1" => fn xml -> SAXMapParser.parse(xml) end,
    # XmlToMapParser is omitted since it crashes on the tested XML.
    # "XmlToMapParser.naive_map/1" => fn xml -> XmlToMapParser.parse(xml) end,
    ":xmerl_scan.string/1" => fn xml -> XmerlScanParser.parse(xml) end
  },
  inputs: xml_inputs,
  time: 5,
  warmup: 2,
  parallel: 4
)

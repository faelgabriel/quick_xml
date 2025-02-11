defmodule QuickXmlFullTest do
  use ExUnit.Case
  doctest QuickXml

  @xml_content """
    <root>
      <title>Sample XML</title>
      <version>1.0</version>
      <metadata>
          <author>John Doe</author>
          <date>2024-02-07</date>
      </metadata>
      <item id="1" type="product">
          <name>Item 1</name>
          <value>10</value>
          <in_stock>true</in_stock>
      </item>
      <description>This is a <strong>bold</strong> statement.</description>
      <image src="https://example.com/image.jpg" />
      <items>
          <item id="2" type="product">
              <name>Item 2</name>
              <value>20.5</value>
          </item>
          <item id="3" type="service">
              <name>Service 1</name>
              <price currency="USD">99.99</price>
          </item>
      </items>
      <script><![CDATA[
          console.log("Hello, World!");
      ]]></script>
  </root>
  """

  @expected_parsed_xml %{
    "description" => %{"$text" => "statement.", "strong" => %{"$text" => "bold"}},
    "image" => %{"@src" => "https://example.com/image.jpg"},
    "item" => %{
      "@id" => "1",
      "@type" => "product",
      "in_stock" => %{"$text" => "true"},
      "name" => %{"$text" => "Item 1"},
      "value" => %{"$text" => "10"}
    },
    "items" => %{
      "item" => %{
        "@id" => "3",
        "@type" => "service",
        "name" => %{"$text" => "Service 1"},
        "price" => %{"$text" => "99.99", "@currency" => "USD"}
      }
    },
    "metadata" => %{"author" => %{"$text" => "John Doe"}, "date" => %{"$text" => "2024-02-07"}},
    "script" => %{"$text" => "\n        console.log(\"Hello, World!\");\n    "},
    "title" => %{"$text" => "Sample XML"},
    "version" => %{"$text" => "1.0"}
  }

  describe "parse/1" do
    test "parses from string" do
      assert {:ok, parsed_xml} = QuickXml.parse(@xml_content)
      assert parsed_xml == @expected_parsed_xml
    end

    test "returns error if xml is invalid" do
      assert {:error, error} = QuickXml.parse("invalid xml")
      assert error == {:invalid_xml, "syntax error: xml must have a node"}
    end

    test "returns error if XML is malformed" do
      malformed_xml = "<root><title>Unclosed"
      assert {:error, {:malformed_xml, message}} = QuickXml.parse(malformed_xml)

      assert message =~
               "ill-formed document: start tag not closed: `</title>` not found before end of input"
    end

    test "returns error if XML is empty" do
      assert {:error, {:unexpected_eof, nil}} = QuickXml.parse("")
    end
  end
end

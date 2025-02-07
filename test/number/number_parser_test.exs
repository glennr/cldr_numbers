defmodule Cldr.Number.Parsing.Test do
  use ExUnit.Case, async: true

  test "parse numbers" do
    assert Cldr.Number.Parser.parse("100", backend: TestBackend.Cldr) == {:ok, 100}
    assert Cldr.Number.Parser.parse("100.0", backend: TestBackend.Cldr) == {:ok, 100.0}
    assert Cldr.Number.Parser.parse("1_000", backend: TestBackend.Cldr) == {:ok, 1000}
    assert Cldr.Number.Parser.parse("+1_000.0", backend: TestBackend.Cldr) == {:ok, 1000.0}
    assert Cldr.Number.Parser.parse("-100", backend: TestBackend.Cldr) == {:ok, -100}
    assert Cldr.Number.Parser.parse(" 100 ", backend: TestBackend.Cldr) == {:ok, 100}
  end

  test "parse numbers with locale other than en" do
    assert Cldr.Number.Parser.parse("1.000,00", backend: TestBackend.Cldr, locale: "de") ==
      {:ok, 1000.0}
  end

  test "scan a number string" do
    assert Cldr.Number.Parser.scan("100 australian dollars", backend: TestBackend.Cldr) ==
      [100, " australian dollars"]

    assert Cldr.Number.Parser.scan("us dollars 100", backend: TestBackend.Cldr) ==
      ["us dollars ", 100]
  end

  test "resolving currency and value" do
     result =
       Cldr.Number.Parser.scan("us dollars 100", backend: TestBackend.Cldr)
       |> Cldr.Number.Parser.resolve_currencies(backend: TestBackend.Cldr)

      assert result == [:USD, 100]

    result2 =
      Cldr.Number.Parser.scan("$100", backend: TestBackend.Cldr)
      |> Cldr.Number.Parser.resolve_currencies(backend: TestBackend.Cldr)

    assert result2 == [:USD, 100]
  end

  test "scanning strings that have symbols in them" do
    assert Cldr.Number.Parser.scan("a string, which I think. Well, sometimes not £1_000_000.34") ==
      ["a string, which I think. Well, sometimes not £", 1000000.34]
  end

  test "parse a decimal" do
    {:ok, parsed} = Cldr.Number.Parser.parse("1.000,00",
      number: :decimal, backend: TestBackend.Cldr, locale: "de")
    assert Cldr.Decimal.compare(parsed, Decimal.from_float(1000.0)) == :eq
  end

  test "Parse a list of numbers separated by comma" do
    assert Cldr.Number.Parser.scan( "Here's my number list: 1111, 2222, 3333, 4444, 55,55", number: :decimal) ==
    ["Here's my number list: ", Decimal.new(1111), ", ", Decimal.new(2222), ", ",
     Decimal.new(3333), ", ", Decimal.new(4444), ", ", Decimal.new(5555)]
  end

  test "Parsing a locale with a grouping character that is a pop space" do
    string = Cldr.Number.to_string!(12345, locale: "fr")
    assert Cldr.Number.Parser.scan(string, locale: "fr") == [12345]
    assert Cldr.Number.Parser.parse(string, locale: "fr") == {:ok, 12345}
  end

  test "Parsing a locale with a grouping character that is a pop space but using 0x20 group char" do
    # pop space is 0x202c
    assert Cldr.Number.Parser.scan("This with normal space 12 345", locale: "fr") ==
      ["This with normal space ", 12345]

    assert Cldr.Number.Parser.scan("This is with pop space 12 345", locale: "fr") ==
      ["This is with pop space ", 12345]

    assert Cldr.Number.Parser.scan("This with normal space 12 345", locale: "en") ==
      ["This with normal space ", 12, " ", 345]
  end

  test "Resolving currencies in a string" do
    scanned = Cldr.Number.Parser.scan("Lets try this 123 US dollars, a bunch of US dollars 23 and 345 euros")
    assert Cldr.Number.Parser.resolve_currencies(scanned) ==
      ["Lets try this ", 123, :USD, ", a bunch of ", :USD, 23, " and ", 345, :EUR]

    scanned = Cldr.Number.Parser.scan("Lets try this 123 US dollars, a bunch of swiss francs 23 and 345 euros")
    assert Cldr.Number.Parser.resolve_currencies(scanned) ==
      ["Lets try this ", 123, :USD, ", a bunch of ", :CHF, 23, " and ", 345, :EUR]
  end

  test "That resolving only happens when there is a non-alpha adjacent char" do
    scanned = Cldr.Number.Parser.scan("These are 100 us dollars and also nonswiss francs")
    assert Cldr.Number.Parser.resolve_currencies(scanned) ==
      ["These are ", 100, :USD, " and also nonswiss francs"]

    scanned = Cldr.Number.Parser.scan("These are 100 us dollars and also non swiss francs")
    assert Cldr.Number.Parser.resolve_currencies(scanned) ==
      ["These are ", 100, :USD, " and also non ", :CHF]

    scanned = Cldr.Number.Parser.scan("These are us dollars 100 and also nonswiss francs")
    assert  Cldr.Number.Parser.resolve_currencies(scanned) ==
      ["These are ", :USD, 100, " and also nonswiss francs"]

    scanned = Cldr.Number.Parser.scan("These areus dollars 100 and also nonswiss francs")
    assert  Cldr.Number.Parser.resolve_currencies(scanned) ==
      ["These areus dollars ", 100, " and also nonswiss francs"]
  end

  test "That parsing returns the same case as the search for strings" do
    scanned = Cldr.Number.Parser.scan( "Try ThCA$2is")
    assert Cldr.Number.Parser.resolve_currencies(scanned) == [:TRY, " ThCA$", 2, "is"]

    scanned = Cldr.Number.Parser.scan( "Try Th CA$2is")
    assert Cldr.Number.Parser.resolve_currencies(scanned) == [:TRY, " Th ", :CAD, 2, "is"]
  end

  test "Resolve currencies when the string is only whitespace" do
    string = ["   "]
    assert Cldr.Number.Parser.resolve_currencies(string) == string
  end
end
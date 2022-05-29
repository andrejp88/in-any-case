module in_any_case;

import core.exception;
import std.algorithm;
import std.array;
import std.conv;
import std.range;
import std.regex;
import std.traits;
import std.uni;

version(unittest) import exceeds_expectations;


/// Convert a string to the given case.
///
/// If no separator is given, the function will attempt to split the
/// input string by spaces, hyphens, or underscores, in that order of
/// priority. If none of those characters are found, splits the string
/// as if it were camelCase/PascalCase.
///
/// If that isn't good enough, pass in an explicit separator as the
/// last parameter. To force the function to split words by
/// camelCase/PascalCase rules (i.e. when an uppercase letter is
/// encountered), pass the empty string `""` as the separator.
public String toCase(String)(in String input, in Case casing)
pure
if (isSomeString!String)
{
    return
        input
        .to!string                  // Do work in UTF-8 so we can avoid everything being templated
        .smartSplit
        .joinUsingCasing(casing)
        .to!String;                 // Convert back to the original string type when done
}
unittest
{
    Case spongebobCase = Case(
        (words) {
            string[] result;

            foreach (string word; words) {
                string newWord;
                foreach (idx, c; word) {
                    import std.uni : toUpper, toLower;

                    if (idx % 2 == 0)
                        newWord ~= c.toLower;
                    else
                        newWord ~= c.toUpper;
                }
                result ~= newWord;
            }

            return result;
        },
        " " // Separate words using spaces
    );

    expect("hello world".toCase(spongebobCase)).toEqual("hElLo wOrLd");
}
unittest
{
    // wstrings and dstrings also work
    expect("hello world"w.toCase(Case.screamingSnake)).toEqual("HELLO_WORLD"w);
    expect("hello world"d.toCase(Case.screamingSnake)).toEqual("HELLO_WORLD"d);
}

/// ditto
public String toCase(String)(in String input, in Case casing, in String separator)
pure
if (isSomeString!String)
{
    return
        input
        .to!string                  // Do work in UTF-8 so we can avoid everything being templated
        .dumbSplit(separator.to!string)
        .joinUsingCasing(casing)
        .to!String;                 // Convert back to the original string type when done
}
unittest
{
    // Use "." as the word separator
    expect("hello.world".toCase(Case.pascal, ".")).toEqual("HelloWorld");

    // Force the input to be interpreted as camelCase or PascalCase
    expect("helLo_woRld".toCase(Case.kebab, "")).toEqual("hel-lo_wo-rld");

    // wstrings and dstrings also work
    expect("hello.world"w.toCase(Case.screamingSnake, ".")).toEqual("HELLO_WORLD"w);
    expect("hello.world"d.toCase(Case.screamingSnake, ".")).toEqual("HELLO_WORLD"d);
}

version(unittest)
{
    private struct TestCase
    {
        Case casing;
        string name;
        string helloWorld;
    }

    private enum TestCase[] testCases = [
        TestCase(Case.pascal, "PascalCase", "Hello123World"),
        TestCase(Case.camel, "camelCase", "hello123World"),
        TestCase(Case.snake, "snake_case", "hello_123_world"),
        TestCase(Case.screamingSnake, "SCREAMING_SNAKE_CASE", "HELLO_123_WORLD"),
        TestCase(Case.kebab, "kebab-case", "hello-123-world"),
        TestCase(Case.sentence, "Sentence case", "Hello 123 world"),
    ];

    static foreach (TestCase from; testCases)
    {
        static foreach (TestCase to; testCases)
        {
            @("Convert from " ~ from.name ~ " to " ~ to.name ~ ": " ~ from.helloWorld ~ " -> " ~ to.helloWorld)
            unittest
            {
                expect(from.helloWorld.toCase(to.casing)).toEqual(to.helloWorld);
            }
        }
    }
}

private alias Capitalizer = string[] function(in string[] words) pure;

private enum Capitalizer sentenceCapitalizer = (in string[] words) {
    string[] result;
    foreach (size_t idx, string word; words)
    {
        if (idx == 0)
            result ~= asCapitalized(word).to!string;
        else
            result ~= word;
    }
    return result;
};

private enum Capitalizer inverseSentenceCapitalizer = (in string[] words) {
    string[] result;
    foreach (size_t idx, string word; words)
    {
        if (idx == 0)
            result ~= word;
        else
            result ~= asCapitalized(word).to!string;
    }
    return result;
};

private enum Capitalizer titleCapitalizer = (in string[] words) {
    return words.map!(word => word.asCapitalized.to!string).array;
};

public enum Capitalizer allCapsCapitalizer = (in string[] words) => words.map!toUpper.array;

public struct Case
{
    public enum Case pascal = Case(titleCapitalizer);
    public enum Case camel = Case(inverseSentenceCapitalizer);
    public enum Case snake = Case(words => words.dup, "_");
    public enum Case screamingSnake = Case(allCapsCapitalizer, "_");
    public enum Case kebab = Case(words => words.dup, "-");
    public enum Case sentence = Case(sentenceCapitalizer, " ");

    Capitalizer capitalizer;
    string separator = "";

    invariant(capitalizer !is null, "capitalizer is null");
}

private string joinUsingCasing(Strings)(in Strings input, in Case casing)
pure
if (isInputRange!Strings && isSomeString!(ElementType!Strings))
{
    return casing.capitalizer(input.map!toLower.array).join(casing.separator);
}

@("join a sequence of words in PascalCase")
unittest
{
    expect(["hello", "world"].joinUsingCasing(Case.pascal)).toEqual("HelloWorld");
}

@("join a sequence of words in camelCase")
unittest
{
    expect(["hello", "world"].joinUsingCasing(Case.camel)).toEqual("helloWorld");
}

@("join a sequence of words in snake_case")
unittest
{
    expect(["hello", "world"].joinUsingCasing(Case.snake)).toEqual("hello_world");
}

@("join a sequence of words in SCREAMING_SNAKE_CASE")
unittest
{
    expect(["hello", "world"].joinUsingCasing(Case.screamingSnake)).toEqual("HELLO_WORLD");
}

@("join a sequence of words in kebab-case")
unittest
{
    expect(["hello", "world"].joinUsingCasing(Case.kebab)).toEqual("hello-world");
}

@("join a sequence of words in Sentence case")
unittest
{
    expect(["hello", "world"].joinUsingCasing(Case.sentence)).toEqual("Hello world");
}

@("join words without changing numbers")
unittest
{
    expect(["123", "abc", "456"].joinUsingCasing(Case.pascal)).toEqual("123Abc456");
    expect(["hello", "001010", "world"].joinUsingCasing(Case.pascal)).toEqual("Hello001010World");
}

/// Attempts to split by spaces, hyphens, or underscores, in that
/// order of priority. If none are found, splits the string as if it
/// were camelCase/PascalCase. Result is a range of strings.
private auto smartSplit(in string input)
pure
{
    if (input.canFind(' '))
        return input.split(" ");
    else if (input.canFind('-'))
        return input.split("-");
    else if (input.canFind('_'))
        return input.split("_");
    else
        return splitOnUpper(input);
}

/// Splits by `separator`. If separator is not given, treats the input
/// as camelCase/PascalCase.  Result is a range of strings.
private auto dumbSplit(in string input, in string separator)
pure
{
    if (separator == "")
        return splitOnUpper(input);
    else
        return input.split(separator);
}

private string[] splitOnUpper(in string input)
pure
{
    string[] result;

    string currentWordSoFar;
    size_t currentStartIdx;
    bool isCurrentANumber;
    foreach (size_t idx, const char c; input)
    {
        if (isNumber(c))
        {
            if (!isCurrentANumber && idx != 0)
            {
                result ~= currentWordSoFar;
                currentStartIdx = idx;
            }

            isCurrentANumber = true;
        }
        else if (isCurrentANumber)
        {
            isCurrentANumber = false;
            result ~= currentWordSoFar;
            currentStartIdx = idx;
        }
        else if (isUpper(c) && idx != 0)
        {
            result ~= currentWordSoFar;
            currentStartIdx = idx;
        }

        currentWordSoFar = input[currentStartIdx .. idx + 1];
    }

    result ~= currentWordSoFar;

    return result;
}

@("split a PascalCase string into a sequence of words")
unittest
{
    expect(smartSplit("HelloWorld")).toEqual(["Hello", "World"]);
}

@("split a camelCase string into a sequence of words")
unittest
{
    expect(smartSplit("helloWorld")).toEqual(["hello", "World"]);
}

@("split a snake_case string into a sequence of words")
unittest
{
    expect(smartSplit("hello_world")).toEqual(["hello", "world"]);
}

@("split a SCREAMING_SNAKE_CASE string into a sequence of words")
unittest
{
    expect(smartSplit("HELLO_WORLD")).toEqual(["HELLO", "WORLD"]);
}

@("split a kebab-case string into a sequence of words")
unittest
{
    expect(smartSplit("hello-world")).toEqual(["hello", "world"]);
}

@("split a Sentence case string into a sequence of words")
unittest
{
    expect(smartSplit("Hello world")).toEqual(["Hello", "world"]);
}

@("split an ambiguous string by spaces")
unittest
{
    expect(smartSplit("he-llo wo_rLd")).toEqual(["he-llo", "wo_rLd"]);
}

@("split numbers apart from words")
unittest
{
    expect(smartSplit("123")).toEqual(["123"]);
    expect(smartSplit("123abc")).toEqual(["123", "abc"]);
    expect(smartSplit("123Abc")).toEqual(["123", "Abc"]);
    expect(smartSplit("abc123")).toEqual(["abc", "123"]);
}

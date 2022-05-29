[![](https://gitlab.com/andrej88/in-any-case/-/raw/v1.0.4/readme-resources/gitlab-icon-rgb.svg) Main Repo](https://gitlab.com/andrej88/in-any-case)   ·   [![](https://gitlab.com/andrej88/in-any-case/-/raw/v1.0.4/readme-resources/github-icon.svg) Mirror](https://github.com/andrejp88/in-any-case)   ·   [![](https://gitlab.com/andrej88/in-any-case/-/raw/v1.0.4/readme-resources/dub-logo-small.png) Dub Package Registry](https://code.dlang.org/packages/in-any-case)   ·   [![](https://gitlab.com/andrej88/in-any-case/-/raw/v1.0.4/readme-resources/documentation-icon.svg) Documentation](https://in-any-case.dpldocs.info/v1.0.4/index.html)

# In Any Case

In any case is a D language library for converting strings into
specific capitalizations.

There are six built-in cases:
```d
writeln("Hello World".toCase(Case.pascal));         // HelloWorld
writeln("Hello World".toCase(Case.camel));          // helloWorld
writeln("Hello World".toCase(Case.snake));          // hello_world
writeln("Hello World".toCase(Case.screamingSnake)); // HELLO_WORLD
writeln("Hello World".toCase(Case.kebab));          // hello-world
writeln("Hello World".toCase(Case.sentence));       // Hello world
```

Custom cases can be defined using the `Case` struct. It takes a
capitalizer function to apply correct casing to words, and an optional
separator to place between words.

```d
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
```

`wstring` (UTF-16) and `dstring` (UTF-32) inputs are accepted, but the
library's internals will convert them to UTF-8 and then back. A bit
wasteful, but it beats having the `Case` struct be a template.

As of v1.0, the library is designed for the ASCII alphabet. Letters beyond those found in English may not be converted as expected.

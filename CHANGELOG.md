# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!-- ## Unreleased -->

## [1.0.0] · 2022-05-28
### Added
- `toCase` function for automatically converting a string to a given casing.
- `Case` struct for defining a casing system using a capitalization function and separator.
- Six predefined casings:
    | Variable name         | Example                |
    |-----------------------|------------------------|
    | `Case.pascal`         | `PascalCase`           |
    | `Case.camel`          | `camelCase`            |
    | `Case.snake`          | `snake_case`           |
    | `Case.screamingSnake` | `SCREAMING_SNAKE_CASE` |
    | `Case.kebab`          | `kebab-case`           |
    | `Case.sentence`       | `Sentence case`        |

[1.0.0]: https://gitlab.com/andrej88/in-any-case/-/tree/v1.0.0

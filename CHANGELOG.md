# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog], and this project adheres to
[Semantic Versioning].

---

<!-- ## Unreleased -->

## [1.0.5] · 2022-06-01
### Fixed
- Fixed linker error when used as a dependency.

---

## [1.0.4] · 2022-05-29
### Fixed
- Loosen dependency on `silly` to not conflict with dependents'
  `silly` versions.

---

## [1.0.3] · 2022-05-29
### Fixed
- Fixed non-unittest build

---

## [1.0.2] · 2022-05-28
### Docs
- Added missing v1.0.1 changelog entry.
- Fixed documentation link in readme.

---

## [1.0.1] · 2022-05-28
### Docs
- Added License file

---

## [1.0.0] · 2022-05-28
### Added
- `toCase` function for automatically converting a string to a given casing.
- `Case` struct for defining a casing system using a capitalization
  function and separator.
- Six predefined casings:
    | Variable name         | Example                |
    |-----------------------|------------------------|
    | `Case.pascal`         | `PascalCase`           |
    | `Case.camel`          | `camelCase`            |
    | `Case.snake`          | `snake_case`           |
    | `Case.screamingSnake` | `SCREAMING_SNAKE_CASE` |
    | `Case.kebab`          | `kebab-case`           |
    | `Case.sentence`       | `Sentence case`        |



[Keep a Changelog]: https://keepachangelog.com/en/1.0.0/
[Semantic Versioning]: https://semver.org/spec/v2.0.0.html
[1.0.0]: https://gitlab.com/andrej88/in-any-case/-/tree/v1.0.0
[1.0.1]: https://gitlab.com/andrej88/in-any-case/-/tree/v1.0.1
[1.0.2]: https://gitlab.com/andrej88/in-any-case/-/tree/v1.0.2
[1.0.3]: https://gitlab.com/andrej88/in-any-case/-/tree/v1.0.3
[1.0.4]: https://gitlab.com/andrej88/in-any-case/-/tree/v1.0.4
[1.0.5]: https://gitlab.com/andrej88/in-any-case/-/tree/v1.0.5

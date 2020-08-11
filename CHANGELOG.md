# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [v4.0.0] - {date}
### Added
- CHANGELOG.md -- \*hint hint\*.
- kcov for coverage.
- visual-test.sh for visually checking results.
- Multiple choice feature.
- Single line option-list feature.
- -c|--cancel option, to add cancel if it's not provided.

### Changed
- Cancel is no longer a default option.
- Title is no longer required.
- test.sh now measures second.millisecond runtime instead of seconds.
- Using VERSION file rather than a hard-coded variable.
- Refractored internal structure to help support here-string input for automation, to ease testing.

### Fixed
- Moved to GitHub CI from Travis-CI, where it just works and coverage can be properly measured.

### Removed
- No more arguments to install.sh.
- Removed `set -euo pipefail` throughout.


----


## [v3.0.0] - 2020/6/17
### Added
- Travis-CI (for shellcheck).
- CLI args as commands: line|list=mode, version, help.
- Installation script install.sh.


### Changed
- Refactored to use ANSI escape sequences instead of clearing and drawing the screen repeatedly.


----


## [v2.0.0] - 2020/6/1
### Changed
- Output selection text rather than index.


----


## [v1.1.0] - 2020/6/1
### Added
- Multiline title support.
- Use vim key binding aliases -- j/k as up/down.
- Output selection index.

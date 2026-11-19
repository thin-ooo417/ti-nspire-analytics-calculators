# Changelog

All notable changes. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and versions follow [Semantic Versioning](https://semver.org/).

## [1.0.0] - 2026-11-19

First public release.

### Fixed since the earlier, unpublished version

- **The last result row could go missing.** The space for results was slightly mis-measured. On `07_Test_Two_Means` the "small sample" warning was worked out but never shown.
- `06_Test_One_Mean` now flags samples under 30, as `07_Test_Two_Means` does.
- `07_Test_Two_Means` shows "s1 / s2 cannot both be 0" instead of dividing by zero.

### Added

- One source file per sheet, with shared code in `src/shared/`.
- A build that needs only Python (`scripts/build.py`).
- Automated tests that run every sheet under Lua 5.1 and check its results.
- A step-by-step guide to loading the sheets with TI-Nspire Computer Link Software, shipped as
  `README.txt` in the download.
- Automatic tests, releases and a weekly dependency check on GitHub.

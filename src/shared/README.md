# Shared code

Each sheet in `src/analytics/` holds its own title, fields and formulas, then pulls in the shared
code here with a line such as `--@include shared/form_columns.lua`. The build pastes the file
in at that point, so every `.tns` file is still one complete script. A fix made here reaches every
sheet that uses the file.

| File | Used by |
|---|---|
| `form_columns.lua` | 14 of 16 sheets |
| `number_format.lua` | 14 of 16 sheets |
| `normal_distribution.lua` | 5 of 16 sheets |

Everything here must run on Lua 5.1 and fit the calculator's 318 × 212 pixel screen.

## `form_columns.lua`

One or two columns of fields with a RESULTS section underneath. The sheet defines `TITLE`, `HINT`,
`COLS` (1 or 2), `FIELDS` (a list of `{lab=..., def=...}`) and a function `compute(v)`, where `v`
holds the values by position (a number, or nil if blank). `compute` returns rows of
`{label, text}`, or `{label, text, "w"}` for a warning. Results are only worked out again when an
input changes, and an error inside `compute` shows "check inputs" instead of stopping the sheet.

Include `shared/number_format.lua` before it (it needs `local abs = math.abs`).
`shared/normal_distribution.lua` adds `normsf` and `normcdf` (it needs `abs` and `exp`).

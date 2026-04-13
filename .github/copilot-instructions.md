# Copilot Instructions

## Commands

```bash
# Install dependencies
bin/setup

# Run all tests
bundle exec rake spec

# Run a single spec file
bundle exec rspec spec/cmd_spec.rb

# Run specs matching a tag
bundle exec rspec --tag yaml

# Lint
bundle exec rubocop

# Interactive console
bin/console

# Install gem locally
bundle exec rake install
```

### CLI usage

```bash
bundle exec ruby bin/cmd yaml  <top_dir> -o <out.yaml> -c <out.csv> [-d <dump>] [-x]
bundle exec ruby bin/cmd csv   <top_dir> -o <out.csv>
bundle exec ruby bin/cmd csv_upload <top_dir>
bundle exec ruby bin/cmd json  <top_dir> -o <out.json> [-d <dump>] [-x]
bundle exec ruby bin/cmd cp2   <top_dir> [-o <output_dir>] [-d <dump>] [-x]
bundle exec ruby bin/cmd fyaml -o <yaml_file>
```

`-x` / `--adont` forces a fresh filesystem scan, bypassing the PStore dump cache.

## Architecture

`cpiconfiles` is a Ruby gem that scans a directory tree for icon files, builds an in-memory representation, and exports results as CSV, YAML, or JSON with optional Google Drive upload.

### Data model (bottom-up)

- **`Iconfile`** — single icon file with metadata (`kind`, `icon_size`, `category`, `l1`, `l2`, `basename`, `pathn`)
- **`Iconfilesubgroup`** — groups `Iconfile` instances sharing a `[category, l1, l2]` key; holds min/max icon size stats
- **`Iconfilegroup`** — groups `Iconfilesubgroup` instances under a directory; owns `collect` (recursive filesystem scan) and `analyze`; `@iconfiles_hs` keyed by `[category]`, `[category, l1]`, or `[category, l1, l2]` arrays
- **`IconfilegroupArray`** — ordered collection of `Iconfilegroup`
- **`Iconlist`** — top-level container; `@iconfilegroups` is a `Hash` keyed by `Pathname`; owns load/dump lifecycle and export methods (`save_as_csv`, `yaml`, `json`, `copy_to`)

### Supporting classes

- **`Sizepattern`** — classifies icon size from a filename via a priority-ordered regex cascade; returns `[way, matched_num, head, tail]`
- **`Sizeddir`** — detects whether a directory name encodes a size (used as `parent_sizeddir` during recursive collect)
- **`Appenv`** — class-level singleton holding the active `Dump` instance; configured once per run via `Appenv.set_dump_file`
- **`Dump`** — wraps `PStore` for binary caching of scan results between runs; skipped when dump file is absent or `-x` flag is passed
- **`Yamlstore`** — serializes/deserializes `Iconlist` and `Iconfilegroup` objects to/from YAML
- **`Loggerxcm`** — thin wrapper around the `loggerx` gem; log level set to `:info` in `Cli#initialize`

### CLI layer

- **`Cmd`** (Thor subclass in `lib/cpiconfiles/cmd.rb`) — defines subcommands: `yaml`, `csv`, `csv_upload`, `cp2`, `json`, `fyaml`, `fjson`; passes `-x`/`--adont` to skip dump; delegates to `Cli`
- **`Cli`** (in `lib/cpiconfiles/cli.rb`) — orchestrates: `setup` → `collect` → `setup_for_iconfiles` → `analyze`, then calls the export method; `initialize` accepts an optional `csv_fname`

### Typical flow

```
Cmd.start(['yaml', top_dir, '-o', out.yaml, '-c', out.csv])
  → Appenv.set_dump_file(...)
  → Cli#yaml
      → Cli#execute_body
          → Iconlist#load          # from PStore if available
          → Iconlist#collect       # filesystem scan via Iconfilegroup#collect_sub
          → Iconlist#setup_for_iconfiles
          → Iconlist#analyze
      → iconlist.save_as_csv(@csv_pn) if @csv_pn
      → Yamlstore.add_iconlist(iconlist)
  → Yamlstore.save(output_fname)
```

### Google Drive integration

Two implementations exist in `lib/cpiconfiles/`:
- **`GDrive`** (`gdrive.rb`) — service-account credentials; used by `Cmd#csv_upload`; uploads CSV as a Google Spreadsheet; reads key from `secret/yk-gdrive-1709fc8c2319.json`
- **`GoogleDrive`** (`google_drive.rb`) — OAuth2 user credentials; reads `JSON_GCPX` env var; not wired to any current subcommand

`Cmd#csv_upload` always writes to `pciconfile.csv` (hardcoded), then uploads with a timestamp suffix.

## Key Conventions

- **Ruby ≥ 3.3.0** (gemspec and `.tool-versions`). Several gems that were removed from stdlib must be declared explicitly in the Gemfile: `logger`, `csv`, `ostruct`, `pstore`
- **RuboCop**: single quotes enforced (`Style/StringLiterals`), max line length 120, `rubocop-rake` and `rubocop-rspec` plugins loaded; see `.rubocop.yml` / `.rubocop_todo.yml`
- **No `frozen_string_literal` magic comment** — `Style/FrozenStringLiteralComment` is disabled
- **RSpec**: use `expect` syntax only (`config.disable_monkey_patching!`); tag tests with symbols (e.g., `:yaml => true`) to run subsets; fixture data lives in `spec/test_data/`
- **CSV format**: columns are `kind,icon_size,category,basename,pathn` (no header row)
- **`Iconlist#valid?`** returns `true` in `:BEFORE_LOAD` state (before any scan), so `collect` is only skipped after a successful dump load (`move_state` transitions the state)
- **`p` statements** remain in production code (e.g., `cmd.rb`) — this is intentional debug output, not a mistake
- **`csvi` subcommand** is unfinished (TODO state)
- **`fjson` subcommand** reads and parses JSON but does nothing with the result yet

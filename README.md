# SpacePreview

A macOS Quick Look extension that renders developer files with syntax highlighting when you press **Space** in Finder.

> **macOS 13+ (Ventura and later), including macOS 15 Sequoia.**
> Built as a modern App Extension (`.appex`), not the legacy `.qlgenerator` format which was removed in macOS 15.

## Supported file types

### Programming Languages (63+)

| Category | Extensions |
|---|---|
| JavaScript | `.js` `.mjs` `.cjs` |
| TypeScript | `.tsx` `.cts` |
| Go | `.go` |
| Java | `.java` |
| Kotlin | `.kt` `.kts` |
| Rust | `.rs` |
| PHP | `.php` |
| Python | `.py` `.pyw` |
| Ruby | `.rb` |
| Shell | `.sh` `.bash` `.zsh` |
| Swift / ObjC | `.swift` `.m` `.mm` |
| C / C++ | `.c` `.h` `.cc` `.cpp` `.cxx` `.hh` |
| Vue | `.vue` |
| CSS / SCSS / Less | `.css` `.scss` `.sass` `.less` |
| HTML / XML | `.html` `.htm` `.xml` `.svg` `.plist` |
| Dart | `.dart` |
| Scala | `.scala` `.sc` |
| Elixir | `.ex` `.exs` |

### Data & Configuration

| Category | Extensions |
|---|---|
| JSON | `.json` `.jsonc` |
| YAML | `.yaml` `.yml` |
| TOML | `.toml` |
| INI / Config | `.ini` `.cfg` `.conf` |
| SQL | `.sql` |
| GraphQL | `.graphql` `.gql` |
| Protobuf | `.proto` |
| Lua | `.lua` |
| R | `.r` |

### DevOps & Infrastructure

| Category | Extensions |
|---|---|
| Terraform / HCL | `.tf` `.tfvars` `.hcl` |
| Dockerfile | `.dockerfile` |
| Makefile | `.makefile` `.mk` |
| Gradle | `.gradle` |
| Jenkinsfile | `Jenkinsfile` |
| Vagrantfile | `Vagrantfile` |
| Gemfile / Podfile | `Gemfile` `Podfile` `.gemfile` `Brewfile` `Fastfile` |

### Subtitles & Text

| Category | Extensions |
|---|---|
| SRT Subtitle | `.srt` |
| ASS/SSA Subtitle | `.ass` `.ssa` |
| Markdown | `.md` `.markdown` *(rendered as HTML)* |
| reStructuredText | `.rst` |
| LaTeX | `.tex` `.latex` |
| Environment | `.env` `.env.example` `.env.local` `.env.production` `.env.staging` `.env.development` |

## Features

- **Syntax highlighting** with the Atom One theme (auto light/dark)
- **Line numbers**
- **Markdown rendering** — `.md` files are rendered as HTML, not shown as raw source
- **Self-contained** — no network access at preview time; all assets bundled
- Follows **system dark/light mode** automatically

## Prerequisites

- macOS 13 Ventura or later (including macOS 15 Sequoia)
- Xcode Command Line Tools — `xcode-select --install`
- Internet access the first time (to download highlight.js and marked.js from cdnjs)

## Installation

### Option A — One command

```bash
bash install.sh
```

### Option B — Manual steps

```bash
# 1. Download JS/CSS dependencies (once)
make deps

# 2. Build SpacePreview.app
make build

# 3. Install to ~/Applications/ and register
make install
```

### Option C — Universal binary (Intel + Apple Silicon)

```bash
make build-universal
make install
```

After installation, open **Finder**, select a supported file, and press **Space**.

## Known limitations

The following file types are **not currently supported** for preview:
- **`.mdown`, `.mkdn`, `.mkd`** — Markdown variants. Use `.md` or `.markdown` instead.
- **`.rmd`** — R Markdown files. Use plain `.md` for preview.
- **`.qmd`** — Quarto documents. Use plain `.md` for preview.
- **`.csv`, `.tsv`, `.tab`** — Data files (CSV/TSV/TAB). Use dedicated spreadsheet tools for better viewing.
- **`.ipynb`** — Jupyter Notebook files. Use Jupyter or VS Code for proper notebook preview.
- **`.ts`** — Plain TypeScript files. Use `.tsx` or `.cts` instead.
- **`.jsx`** — JSX files. Use plain `.js` or `.tsx` instead.
- **`.mts`** — TypeScript module files. Use `.tsx` or `.cts` instead.
- **`.cs`** — C# files
- **`.vtt`** — WebVTT subtitle files
- **`.ps1`** — PowerShell scripts
- **`.fish`** — Fish shell scripts

If you encounter issues with other file types, please report them.

## Troubleshooting

### Preview doesn't appear

Run the fix-perms helper which re-registers the extension and resets the QL cache:

```bash
make fix-perms
```

If that doesn't help, verify the extension is registered:

```bash
pluginkit -m -i com.spacepreview.qlextension
```

You should see a line like:
```
+ com.spacepreview.qlextension(1.0)  ...SpacePreviewQL.appex
```

The `+` means the extension is enabled. If it shows `-`, run:

```bash
pluginkit -e use -i com.spacepreview.qlextension
qlmanage -r && qlmanage -r cache
```

### macOS security prompt

On first use macOS may ask whether to allow SpacePreview to access files. Click **OK**.

## Uninstall

```bash
make uninstall
```

## Project structure

```
SpacePreview/
├── Sources/
│   ├── PreviewProvider.swift   # QLPreviewProvider App Extension entry point
│   ├── FileRenderer.swift      # Builds self-contained HTML
│   ├── LanguageMapping.swift   # Extension → highlight.js language ID
│   └── AppStub/
│       └── main.swift          # Minimal stub for the container .app
├── Resources/
│   ├── preview.html            # HTML template with {{placeholders}}
│   ├── style.css               # Layout, line numbers, Markdown styles
│   ├── highlight.min.js        # (downloaded by make deps)
│   ├── marked.min.js           # (downloaded by make deps)
│   ├── atom-one-light.min.css  # (downloaded by make deps)
│   └── atom-one-dark.min.css   # (downloaded by make deps)
├── Extension-Info.plist        # .appex bundle metadata, UTI declarations
├── App-Info.plist              # Container .app metadata
├── Makefile
└── install.sh
```

## How it works

SpacePreview is a **Quick Look App Extension** (`.appex`), the modern replacement for the legacy `.qlgenerator` format removed in macOS 15.

The extension is embedded inside a container `SpacePreview.app` installed to `~/Applications/`. macOS discovers and registers the extension automatically via `pluginkit`.

When you press Space on a supported file in Finder, macOS invokes `providePreview(for:completionHandler:)` on the `PreviewProvider` class. It:

1. Reads the file content (UTF-8, falling back to Latin-1)
2. Detects the language from the file extension
3. Loads the HTML template and all JS/CSS from the bundle's `Resources/` directory
4. Inlines everything into a single self-contained HTML document
5. Returns the HTML bytes wrapped in a `QLPreviewReply` to Quick Look for rendering

No network requests are made at preview time.

## macOS 15 compatibility note

macOS 15 Sequoia removed `quicklookd` entirely. The old CFPlugin-based `.qlgenerator` format no longer works. SpacePreview uses the `QLPreviewProvider` API introduced in macOS 12, which is the only supported approach going forward.

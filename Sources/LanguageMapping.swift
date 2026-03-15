import Foundation

/// Maps file extensions to highlight.js language identifiers and display names.
enum LanguageMapping {

    struct Info {
        let hljs: String    // highlight.js language ID
        let display: String // Human-readable language name
        let isMarkdown: Bool
    }

    /// Lookup by exact filename (lowercased) for extensionless files like Dockerfile.
    static func info(forFileName name: String) -> Info {
        switch name.lowercased() {
        case "dockerfile":
            return Info(hljs: "dockerfile", display: "Dockerfile", isMarkdown: false)
        case "makefile", "gnumakefile":
            return Info(hljs: "makefile", display: "Makefile", isMarkdown: false)
        case ".env", ".env.example", ".env.local", ".env.production", ".env.staging", ".env.development":
            return Info(hljs: "bash", display: "Env", isMarkdown: false)
        case "jenkinsfile":
            return Info(hljs: "groovy", display: "Jenkinsfile", isMarkdown: false)
        case "vagrantfile":
            return Info(hljs: "ruby", display: "Vagrantfile", isMarkdown: false)
        case "gemfile", "podfile":
            return Info(hljs: "ruby", display: name.capitalized, isMarkdown: false)
        case "brewfile":
            return Info(hljs: "ruby", display: "Brewfile", isMarkdown: false)
        case "fastfile":
            return Info(hljs: "ruby", display: "Fastfile", isMarkdown: false)
        default:
            return Info(hljs: "plaintext", display: "Text", isMarkdown: false)
        }
    }

    // swiftlint:disable cyclomatic_complexity
    static func info(for ext: String) -> Info {
        switch ext {
        // --- Web / Frontend ---
        case "tsx", "cts":
            return Info(hljs: "typescript", display: "TypeScript", isMarkdown: false)
        case "js", "mjs", "cjs":
            return Info(hljs: "javascript", display: "JavaScript", isMarkdown: false)
        case "vue":
            return Info(hljs: "xml", display: "Vue", isMarkdown: false)
        case "html", "htm":
            return Info(hljs: "xml", display: "HTML", isMarkdown: false)
        case "css":
            return Info(hljs: "css", display: "CSS", isMarkdown: false)
        case "scss":
            return Info(hljs: "scss", display: "SCSS", isMarkdown: false)
        case "sass":
            return Info(hljs: "scss", display: "Sass", isMarkdown: false)
        case "less":
            return Info(hljs: "less", display: "Less", isMarkdown: false)

        // --- Systems / Backend ---
        case "go":
            return Info(hljs: "go", display: "Go", isMarkdown: false)
        case "swift":
            return Info(hljs: "swift", display: "Swift", isMarkdown: false)
        case "java":
            return Info(hljs: "java", display: "Java", isMarkdown: false)
        case "kt", "kts":
            return Info(hljs: "kotlin", display: "Kotlin", isMarkdown: false)
        case "rs":
            return Info(hljs: "rust", display: "Rust", isMarkdown: false)
        case "cpp", "cc", "cxx":
            return Info(hljs: "cpp", display: "C++", isMarkdown: false)
        case "c":
            return Info(hljs: "c", display: "C", isMarkdown: false)
        case "h", "hh":
            return Info(hljs: "c", display: "C Header", isMarkdown: false)
        case "m", "mm":
            return Info(hljs: "objectivec", display: "Objective-C", isMarkdown: false)

        // --- Scripting ---
        case "py", "pyw":
            return Info(hljs: "python", display: "Python", isMarkdown: false)
        case "rb":
            return Info(hljs: "ruby", display: "Ruby", isMarkdown: false)
        case "php":
            return Info(hljs: "php", display: "PHP", isMarkdown: false)
        case "sh", "bash":
            return Info(hljs: "bash", display: "Shell", isMarkdown: false)
        case "zsh":
            return Info(hljs: "bash", display: "Zsh", isMarkdown: false)
        case "lua":
            return Info(hljs: "lua", display: "Lua", isMarkdown: false)
        case "r":
            return Info(hljs: "r", display: "R", isMarkdown: false)
        case "dart":
            return Info(hljs: "dart", display: "Dart", isMarkdown: false)
        case "scala":
            return Info(hljs: "scala", display: "Scala", isMarkdown: false)
        case "ex", "exs":
            return Info(hljs: "elixir", display: "Elixir", isMarkdown: false)

        // --- Data / Config ---
        case "json", "jsonc":
            return Info(hljs: "json", display: "JSON", isMarkdown: false)
        case "yaml", "yml":
            return Info(hljs: "yaml", display: "YAML", isMarkdown: false)
        case "toml":
            return Info(hljs: "ini", display: "TOML", isMarkdown: false)
        case "ini", "cfg", "conf":
            return Info(hljs: "ini", display: "INI", isMarkdown: false)
        case "xml", "svg", "plist":
            return Info(hljs: "xml", display: "XML", isMarkdown: false)
        case "sql":
            return Info(hljs: "sql", display: "SQL", isMarkdown: false)
        case "graphql", "gql":
            return Info(hljs: "graphql", display: "GraphQL", isMarkdown: false)
        case "proto":
            return Info(hljs: "protobuf", display: "Protobuf", isMarkdown: false)

        // --- DevOps ---
        case "dockerfile":
            return Info(hljs: "dockerfile", display: "Dockerfile", isMarkdown: false)
        case "tf", "tfvars":
            return Info(hljs: "hcl", display: "Terraform", isMarkdown: false)
        case "makefile", "mk":
            return Info(hljs: "makefile", display: "Makefile", isMarkdown: false)
        case "gradle":
            return Info(hljs: "groovy", display: "Gradle", isMarkdown: false)

        // --- Documentation ---
        case "md", "markdown":
            return Info(hljs: "markdown", display: "Markdown", isMarkdown: true)
        case "rst":
            return Info(hljs: "plaintext", display: "reStructuredText", isMarkdown: false)
        case "tex", "latex":
            return Info(hljs: "latex", display: "LaTeX", isMarkdown: false)

        // --- Subtitles ---
        case "srt":
            return Info(hljs: "plaintext", display: "SRT Subtitle", isMarkdown: false)
        case "ass":
            return Info(hljs: "ini", display: "ASS Subtitle", isMarkdown: false)
        case "ssa":
            return Info(hljs: "ini", display: "SSA Subtitle", isMarkdown: false)

        default:
            return Info(hljs: "plaintext", display: ext.isEmpty ? "Text" : ext.uppercased(), isMarkdown: false)
        }
    }
    // swiftlint:enable cyclomatic_complexity
}

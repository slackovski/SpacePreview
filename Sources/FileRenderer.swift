import Foundation

/// Generates a self-contained HTML string for Quick Look to render.
///
/// All JavaScript and CSS dependencies (highlight.js, marked.js, theme CSS) are loaded
/// from the plugin bundle and inlined into the HTML — no network requests needed.
final class FileRenderer {

    private let bundle: Bundle

    init(bundle: Bundle) {
        self.bundle = bundle
    }

    // MARK: - Public API

    func render(content: String, fileExtension ext: String, fileName: String) -> String {
        // For extensionless files (e.g. Dockerfile, Makefile) fall back to filename lookup.
        let langInfo = ext.isEmpty
            ? LanguageMapping.info(forFileName: fileName)
            : LanguageMapping.info(for: ext)

        // Load resources from the plugin bundle.
        let highlightJS   = resource("highlight.min",       ext: "js")
        let markedJS      = resource("marked.min",          ext: "js")
        let lightThemeCSS = resource("atom-one-light.min",  ext: "css")
        let darkThemeCSS  = resource("atom-one-dark.min",   ext: "css")
        let styleCSS      = resource("style",               ext: "css")
        let templateHTML  = resource("preview",             ext: "html")

        guard !highlightJS.isEmpty, !templateHTML.isEmpty else {
            return fallbackHTML(content: content, fileName: fileName)
        }

        let escapedContent = htmlEscape(content)
        let escapedFileName = htmlEscape(fileName)

        return templateHTML
            .replacingOccurrences(of: "{{FILE_NAME}}",          with: escapedFileName)
            .replacingOccurrences(of: "{{LANGUAGE}}",           with: langInfo.hljs)
            .replacingOccurrences(of: "{{LANG_DISPLAY}}",       with: langInfo.display)
            .replacingOccurrences(of: "{{CODE_CONTENT}}",       with: escapedContent)
            .replacingOccurrences(of: "{{IS_MARKDOWN}}",        with: langInfo.isMarkdown ? "true" : "false")
            .replacingOccurrences(of: "{{HIGHLIGHT_LIGHT_CSS}}", with: lightThemeCSS)
            .replacingOccurrences(of: "{{HIGHLIGHT_DARK_CSS}}",  with: darkThemeCSS)
            .replacingOccurrences(of: "{{STYLE_CSS}}",          with: styleCSS)
            .replacingOccurrences(of: "{{HIGHLIGHT_JS}}",       with: highlightJS)
            .replacingOccurrences(of: "{{MARKED_JS}}",          with: markedJS)
    }

    // MARK: - Private helpers

    private func resource(_ name: String, ext: String) -> String {
        guard let url = bundle.url(forResource: name, withExtension: ext),
              let content = try? String(contentsOf: url, encoding: .utf8) else {
            return ""
        }
        return content
    }

    private func htmlEscape(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&",  with: "&amp;")
            .replacingOccurrences(of: "<",  with: "&lt;")
            .replacingOccurrences(of: ">",  with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'",  with: "&#39;")
    }

    /// Minimal fallback when bundle resources are missing.
    private func fallbackHTML(content: String, fileName: String) -> String {
        """
        <!DOCTYPE html>
        <html>
        <head><meta charset="utf-8"><title>\(htmlEscape(fileName))</title>
        <style>body{font-family:monospace;padding:16px;white-space:pre-wrap;}</style>
        </head>
        <body>\(htmlEscape(content))</body>
        </html>
        """
    }
}

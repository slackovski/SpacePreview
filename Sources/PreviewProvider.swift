import QuickLookUI
import Foundation

// MARK: - Quick Look Extension entry point (macOS 12+, App Extension model)

/// The principal class for the SpacePreviewQL Quick Look extension.
/// Returns an HTML-based preview for developer files.
@objc(PreviewProvider)
final class PreviewProvider: QLPreviewProvider, QLPreviewingController {

    // Called by the Quick Look system to generate a data-based preview.
    func providePreview(for request: QLFilePreviewRequest,
                        completionHandler handler: @escaping (QLPreviewReply?, Error?) -> Void) {
        let url      = request.fileURL
        let ext      = url.pathExtension.lowercased()
        let fileName = url.lastPathComponent

        // Binary files (e.g. real MPEG-2 .ts video files) contain null bytes.
        // If we detect a null byte in the first 8 KB, skip and let the system handle it.
        if looksLikeBinary(url) {
            handler(nil, nil)
            return
        }

        // Try UTF-8, fall back to Latin-1 for legacy/mixed-encoding files.
        let content: String
        if let utf8 = try? String(contentsOf: url, encoding: .utf8) {
            content = utf8
        } else if let latin1 = try? String(contentsOf: url, encoding: .isoLatin1) {
            content = latin1
        } else {
            handler(nil, NSError(domain: "com.spacepreview.qlextension", code: 1,
                                 userInfo: [NSLocalizedDescriptionKey: "Cannot read file content"]))
            return
        }

        let bundle   = Bundle(for: PreviewProvider.self)
        let renderer = FileRenderer(bundle: bundle)
        let html     = renderer.render(content: content, fileExtension: ext, fileName: fileName)

        guard let htmlData = html.data(using: .utf8) else {
            handler(nil, NSError(domain: "com.spacepreview.qlextension", code: 2,
                                 userInfo: [NSLocalizedDescriptionKey: "Failed to encode HTML"]))
            return
        }

        let reply = QLPreviewReply(
            dataOfContentType: .html,
            contentSize: CGSize(width: 900, height: 700)
        ) { _ in htmlData }

        handler(reply, nil)
    }

    // Reads up to 8 KB and returns true if any null byte is found.
    // All real source-code / config files are null-free; binary formats are not.
    private func looksLikeBinary(_ url: URL) -> Bool {
        guard let fh = try? FileHandle(forReadingFrom: url) else { return false }
        defer { try? fh.close() }
        let sample = (try? fh.read(upToCount: 8192)) ?? Data()
        return sample.contains(0x00)
    }
}

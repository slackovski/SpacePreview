import Foundation
import QuickLook

// MARK: - Bundle locator
// Swift classes inside a plugin bundle allow us to resolve the bundle path at runtime.
private class BundleLocator: NSObject {}

// MARK: - Quick Look generator entry points

/// Called by the Quick Look daemon when a preview is requested.
@_cdecl("GeneratePreviewForURL")
public func generatePreviewForURL(
    _ preview: QLPreviewRequest,   // renamed from QLPreviewRequestRef in newer SDKs
    _ url: CFURL,
    _ contentTypeUTI: CFString,
    _ options: CFDictionary
) -> OSStatus {
    guard !QLPreviewRequestIsCancelled(preview) else { return noErr }

    let fileURL = url as URL
    let ext = fileURL.pathExtension.lowercased()
    let fileName = fileURL.lastPathComponent

    // Binary detection: TypeScript source never contains null bytes; MPEG-2
    // transport streams (real video .ts) do.  Return noErr without a preview
    // so the system can fall through to an appropriate handler.
    if let handle = try? FileHandle(forReadingFrom: fileURL) {
        let sample = handle.readData(ofLength: 8 * 1024)
        handle.closeFile()
        if sample.contains(0x00) { return noErr }
    }

    guard !QLPreviewRequestIsCancelled(preview) else { return noErr }

    // Attempt UTF-8 first, fall back to Latin-1 for older or mixed-encoding files.
    let content: String
    if let utf8 = try? String(contentsOf: fileURL, encoding: .utf8) {
        content = utf8
    } else if let latin1 = try? String(contentsOf: fileURL, encoding: .isoLatin1) {
        content = latin1
    } else {
        return noErr
    }

    guard !QLPreviewRequestIsCancelled(preview) else { return noErr }

    let bundle = Bundle(for: BundleLocator.self)
    let renderer = FileRenderer(bundle: bundle)
    let html = renderer.render(content: content, fileExtension: ext, fileName: fileName)

    guard let data = html.data(using: .utf8) else { return noErr }

    // "public.html" is the stable string for kUTTypeHTML across all macOS versions.
    let htmlUTI = "public.html" as CFString
    QLPreviewRequestSetDataRepresentation(preview, data as CFData, htmlUTI, nil)

    return noErr
}

/// Called by the Quick Look daemon to cancel an in-progress preview.
@_cdecl("CancelPreviewGeneration")
public func cancelPreviewGeneration(_ preview: QLPreviewRequest) {
    // QLPreviewRequestAbortRendering was removed in newer SDKs; no-op is safe.
}

import Foundation

// SpacePreview container app stub
// On first launch, automatically enables the Quick Look extension so users don't need
// to manually run complex pluginkit commands. Subsequent launches are no-ops.

let defaults = UserDefaults.standard
let hasInitialized = defaults.bool(forKey: "SpacePreviewInitialized")

if !hasInitialized {
    // First launch: enable the extension and reset Quick Look

    // Enable extension
    let pluginkit = Process()
    pluginkit.executableURL = URL(fileURLWithPath: "/usr/bin/pluginkit")
    pluginkit.arguments = ["-e", "use", "-i", "com.spacepreview.qlextension"]
    try? pluginkit.run()
    pluginkit.waitUntilExit()

    // Reset Quick Look daemon
    let qlmanage = Process()
    qlmanage.executableURL = URL(fileURLWithPath: "/usr/bin/qlmanage")
    qlmanage.arguments = ["-r"]
    try? qlmanage.run()
    qlmanage.waitUntilExit()

    // Mark as initialized
    defaults.set(true, forKey: "SpacePreviewInitialized")
}

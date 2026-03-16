import AppKit
import UserNotifications

// SpacePreview App Stub
// On first launch: registers the Quick Look extension and shows a system notification.
// On subsequent launches: exits immediately.

class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        let defaults = UserDefaults.standard

        if !defaults.bool(forKey: "SpacePreviewInitialized") {
            // Step 1: Enable the Quick Look extension
            registerExtension()

            // Step 2: Request notification permission and send success notification
            sendInstallNotification()

            // Step 3: Mark as initialized so this never runs again
            defaults.set(true, forKey: "SpacePreviewInitialized")
            defaults.synchronize()
        }

        // Exit silently — this app has no UI to show
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            NSApplication.shared.terminate(nil)
        }
    }

    // MARK: - Extension Registration

    private func registerExtension() {
        let pluginkit = Process()
        pluginkit.executableURL = URL(fileURLWithPath: "/usr/bin/pluginkit")
        pluginkit.arguments = ["-e", "use", "-i", "com.spacepreview.qlextension"]
        try? pluginkit.run()
        pluginkit.waitUntilExit()

        let qlmanage = Process()
        qlmanage.executableURL = URL(fileURLWithPath: "/usr/bin/qlmanage")
        qlmanage.arguments = ["-r"]
        try? qlmanage.run()
        qlmanage.waitUntilExit()
    }

    // MARK: - System Notification

    private func sendInstallNotification() {
        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }

            let content = UNMutableNotificationContent()
            content.title = "SpacePreview 已安装 ✅"
            content.body = "Quick Look 扩展已启用。在 Finder 中选择代码文件，按空格键即可预览。"
            content.sound = .default

            let request = UNNotificationRequest(
                identifier: "com.spacepreview.installed",
                content: content,
                trigger: nil   // nil = deliver immediately
            )

            center.add(request)
        }
    }
}

// Entry point
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()

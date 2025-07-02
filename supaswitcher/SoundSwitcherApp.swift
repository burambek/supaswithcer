import SwiftUI
import AppKit

@main
struct SoundSwitcherApp: App {
    @StateObject private var soundDeviceManager = SoundDeviceManager()
    @StateObject private var hotkeyManager = HotkeyManager()
    
    var body: some Scene {
        MenuBarExtra {
            MenuBarExtraView()
                .environmentObject(soundDeviceManager)
                // Invisible view ensures hotkeys set up at launch
                .background(
                    HotkeySetupView()
                        .environmentObject(soundDeviceManager)
                        .environmentObject(hotkeyManager)
                )
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "speaker.wave.2.fill")
                if let outputDevice = soundDeviceManager.currentOutputDevice {
                    Text(outputDevice.name)
                        .font(.system(size: 12))
                        .lineLimit(1)
                }
            }
        }
        .menuBarExtraStyle(.window)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About Sound Switcher") {
                    showAboutWindow()
                }
            }
        }
    }
    
    private func showAboutWindow() {
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Sound Switcher"
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        let copyright = Bundle.main.object(forInfoDictionaryKey: "NSHumanReadableCopyright") as? String ?? ""
        
        let alert = NSAlert()
        alert.messageText = "About \(appName)"
        alert.informativeText = "Version \(version)\n\nCopyright © \(copyright)"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

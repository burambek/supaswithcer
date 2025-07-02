import HotKey
import Foundation
import AppKit

class HotkeyManager: ObservableObject {
    private var inputHotkey: HotKey?
    private var outputHotkey: HotKey?

    func setupHotkeys(soundDeviceManager: SoundDeviceManager) {
        inputHotkey = HotKey(key: .nine, modifiers: [.option], keyDownHandler: {
            soundDeviceManager.toggleBetweenDevices(isInput: true)
        })
        outputHotkey = HotKey(key: .zero, modifiers: [.option], keyDownHandler: {
            soundDeviceManager.toggleBetweenDevices(isInput: false)
        })

    }
}

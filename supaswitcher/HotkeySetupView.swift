//
//  HotkeySetupView.swift
//  supaswitcher
//
//  Created by Kostiantyn Zhuha on 01.07.2025.
//


import SwiftUI

struct HotkeySetupView: View {
    @EnvironmentObject var soundDeviceManager: SoundDeviceManager
    @EnvironmentObject var hotkeyManager: HotkeyManager
    @State private var didSetupHotkeys = false

    var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .onAppear {
                if !didSetupHotkeys {
                    hotkeyManager.setupHotkeys(soundDeviceManager: soundDeviceManager)
                    didSetupHotkeys = true
                }
            }
    }
}

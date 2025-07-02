import SwiftUI

struct MenuBarExtraView: View {
    @EnvironmentObject var soundDeviceManager: SoundDeviceManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Input Devices").font(.headline)
            ForEach(soundDeviceManager.inputDevices) { device in
                Button(action: {
                    soundDeviceManager.setInputDevice(device)
                    NSApp.sendAction(#selector(NSPopover.performClose(_:)), to: nil, from: nil)
                }) {
                    HStack {
                        Image(systemName: soundDeviceManager.currentInputDevice == device ? "circle.inset.filled" : "circle")
                            .foregroundColor(.accentColor)
                        Text(device.name)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Divider()
            
            Text("Output Devices").font(.headline)
            ForEach(soundDeviceManager.outputDevices) { device in
                Button(action: {
                    soundDeviceManager.setOutputDevice(device)
                    NSApp.sendAction(#selector(NSPopover.performClose(_:)), to: nil, from: nil)
                }) {
                    HStack {
                        Image(systemName: soundDeviceManager.currentOutputDevice == device ? "circle.inset.filled" : "circle")
                            .foregroundColor(.accentColor)
                        Text(device.name)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Option+9 to toggle input devices")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("Option+0 to toggle output devices")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 2)
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding()
        .frame(width: 250)
    }
}

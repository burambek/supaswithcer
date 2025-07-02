import AudioToolbox
import SwiftUI

class SoundDeviceManager: ObservableObject {
    @Published var inputDevices: [AudioDevice] = []
    @Published var outputDevices: [AudioDevice] = []
    @Published var currentInputDevice: AudioDevice?
    @Published var currentOutputDevice: AudioDevice?

    init() {
        refreshDevices()
        setupDeviceChangeListener()
    }

    func refreshDevices() {
        inputDevices = getDevices(isInput: true)
        outputDevices = getDevices(isInput: false)
        currentInputDevice = getCurrentDevice(isInput: true)
        currentOutputDevice = getCurrentDevice(isInput: false)
    }

    private func getDevices(isInput: Bool) -> [AudioDevice] {
        var deviceIDs = [AudioDeviceID]()
        var propertySize: UInt32 = 0
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &propertyAddress, 0, nil, &propertySize)
        let deviceCount = Int(propertySize) / MemoryLayout<AudioDeviceID>.size
        deviceIDs = [AudioDeviceID](repeating: 0, count: deviceCount)
        AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &propertyAddress, 0, nil, &propertySize, &deviceIDs)
        return deviceIDs.compactMap { deviceID in
            guard let name = getDeviceName(deviceID: deviceID),
                  hasChannels(deviceID: deviceID, isInput: isInput) else {
                return nil
            }
            return AudioDevice(
                id: deviceID,
                name: name,
                isInput: isInput,
                isOutput: !isInput
            )
        }
    }

    private func getDeviceName(deviceID: AudioDeviceID) -> String? {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioObjectPropertyName,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var propertySize = UInt32(MemoryLayout<CFString?>.size)
        var name: CFString? = nil
        let status = withUnsafeMutablePointer(to: &name) { namePtr in
            AudioObjectGetPropertyData(
                deviceID,
                &propertyAddress,
                0,
                nil,
                &propertySize,
                namePtr
            )
        }
        return status == noErr ? (name as String?) : nil
    }

    private func hasChannels(deviceID: AudioDeviceID, isInput: Bool) -> Bool {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreamConfiguration,
            mScope: isInput ? kAudioDevicePropertyScopeInput : kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        var propertySize: UInt32 = 0
        AudioObjectGetPropertyDataSize(deviceID, &propertyAddress, 0, nil, &propertySize)
        let bufferList = UnsafeMutablePointer<AudioBufferList>.allocate(capacity: Int(propertySize))
        defer { bufferList.deallocate() }
        let status = AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, nil, &propertySize, bufferList)
        if status != noErr { return false }
        let buffers = UnsafeMutableAudioBufferListPointer(bufferList)
        return buffers.contains { $0.mNumberChannels > 0 }
    }

    private func getCurrentDevice(isInput: Bool) -> AudioDevice? {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: isInput ? kAudioHardwarePropertyDefaultInputDevice : kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var deviceID: AudioDeviceID = 0
        var propertySize = UInt32(MemoryLayout<AudioDeviceID>.size)
        let status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &propertySize,
            &deviceID
        )
        if status == noErr, let name = getDeviceName(deviceID: deviceID) {
            return AudioDevice(
                id: deviceID,
                name: name,
                isInput: isInput,
                isOutput: !isInput
            )
        }
        return nil
    }

    func setInputDevice(_ device: AudioDevice) {
        setDevice(device, isInput: true)
    }

    func setOutputDevice(_ device: AudioDevice) {
        setDevice(device, isInput: false)
    }

    private func setDevice(_ device: AudioDevice, isInput: Bool) {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: isInput ? kAudioHardwarePropertyDefaultInputDevice : kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var deviceID = device.id
        let propertySize = UInt32(MemoryLayout<AudioDeviceID>.size)
        AudioObjectSetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            propertySize,
            &deviceID
        )
        if isInput {
            currentInputDevice = device
        } else {
            currentOutputDevice = device
        }
    }

    private func setupDeviceChangeListener() {
        // Listen for default device changes
        var inputPropertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var outputPropertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        // Listen for device add/remove
        var deviceListPropertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        let callback: AudioObjectPropertyListenerProc = { (_, _, _, context) in
            guard let context = context else { return noErr }
            let manager = Unmanaged<SoundDeviceManager>.fromOpaque(context).takeUnretainedValue()
            DispatchQueue.main.async {
                manager.refreshDevices()
            }
            return noErr
        }
        let contextPtr = Unmanaged.passUnretained(self).toOpaque()
        AudioObjectAddPropertyListener(AudioObjectID(kAudioObjectSystemObject), &inputPropertyAddress, callback, contextPtr)
        AudioObjectAddPropertyListener(AudioObjectID(kAudioObjectSystemObject), &outputPropertyAddress, callback, contextPtr)
        AudioObjectAddPropertyListener(AudioObjectID(kAudioObjectSystemObject), &deviceListPropertyAddress, callback, contextPtr)
    }

    func toggleBetweenDevices(isInput: Bool) {
        let devices = isInput ? inputDevices : outputDevices
        guard devices.count > 1 else { return }
        let currentDevice = isInput ? currentInputDevice : currentOutputDevice
        var nextIndex = 0
        if let current = currentDevice, let index = devices.firstIndex(of: current) {
            nextIndex = (index + 1) % devices.count
        }
        let nextDevice = devices[nextIndex]
        if isInput {
            setInputDevice(nextDevice)
        } else {
            setOutputDevice(nextDevice)
        }
    }
}

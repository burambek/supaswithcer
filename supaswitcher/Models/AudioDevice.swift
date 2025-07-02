import AudioToolbox

struct AudioDevice: Identifiable, Equatable {
    let id: AudioDeviceID
    let name: String
    let isInput: Bool
    let isOutput: Bool
    
    static func == (lhs: AudioDevice, rhs: AudioDevice) -> Bool {
        return lhs.id == rhs.id
    }
}

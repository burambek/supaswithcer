import SwiftUI

enum ToastType: Equatable { // Added Equatable conformance
    case success
    case info
    case warning
    case error
    
    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .info: return "info.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .error: return "xmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .success: return .green
        case .info: return .blue
        case .warning: return .yellow
        case .error: return .red
        }
    }
}

struct Toast: Identifiable, Equatable { // Added Identifiable and Equatable conformance
    let id = UUID() // Required for Identifiable
    var message: String
    var type: ToastType = .info
    var duration: TimeInterval = 2.0
    
    // Equatable conformance: Compare relevant properties for logical equality
    static func == (lhs: Toast, rhs: Toast) -> Bool {
        return lhs.id == rhs.id &&
               lhs.message == rhs.message &&
               lhs.type == rhs.type &&
               lhs.duration == rhs.duration
    }
}

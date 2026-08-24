import Foundation

extension Date {
    var chatTimestamp: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = Calendar.current.isDateInToday(self) ? .none : .short
        return formatter.string(from: self)
    }
}

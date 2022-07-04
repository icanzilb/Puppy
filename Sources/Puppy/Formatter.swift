import Foundation

public protocol LogFormattable {
    func formatMessage(_ level: LogLevel, message: String, tag: String, function: String, file: String, line: UInt, swiftLogInfo: [String: String], label: String, date: Date, threadID: UInt64) -> String
}

extension LogFormattable {
    public func shortFileName(_ file: String) -> String {
        return URL(fileURLWithPath: file).lastPathComponent
    }
}

public func dateFormatter(_ date: Date, locale: String = "en_US_POSIX", dateFormat: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ", timeZone: String = "") -> String {
    let formatterKey = locale + dateFormat + timeZone
    if let formatter = formatterQueue.sync(execute: { formatters[formatterKey] }) {
        return formatter.string(from: date)
    }
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: locale)
    dateFormatter.dateFormat = dateFormat
    dateFormatter.timeZone = TimeZone(identifier: timeZone)
    formatterQueue.sync(flags: .barrier, execute: { formatters[formatterKey] = dateFormatter })
    return dateFormatter.string(from: date)
}

private let formatterQueue = DispatchQueue(label: "formatter", qos: .default, attributes: .concurrent)
private var formatters = [String: DateFormatter]()

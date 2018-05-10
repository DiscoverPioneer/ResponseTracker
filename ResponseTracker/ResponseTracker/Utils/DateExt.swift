import Foundation
import UIKit

extension Date {

    func toString(_ dateFormat: String = "yyyy-MM-dd hh:mm a") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.locale = Locale.current
        dateFormatter.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        return dateFormatter.string(from: self)
    }

    func startOfMonth() -> Date {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        let utcDate = dateFrom(components: components)
        return toLocal(date: utcDate)
    }

    func startOfYear() -> Date {
        let components = Calendar.current.dateComponents([.year], from: self)
        let utcDate = dateFrom(components: components)
        return toLocal(date: utcDate)
    }

    func startOfPreviousMonth() -> Date {
        var components = Calendar.current.dateComponents([.year, .month], from: self)
        if components.month != nil {
            components.month! -= 1
        }
        let utcDate = dateFrom(components: components)
        return toLocal(date: utcDate)
    }

    func dateFrom(components: DateComponents) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.default
        return calendar.date(from: components)!
    }

    func toLocal(date: Date) -> Date {
        let timeZone = NSTimeZone.local
        let seconds = timeZone.secondsFromGMT(for: date)
        return Date(timeInterval: Double(seconds), since: date)
    }
}


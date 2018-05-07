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

    func isStartOfMonth() -> Bool {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale.current
        print("start of month \(dateFormatter.string(from: Calendar.current.date(from: components)!))")

        return dateFormatter.string(from: Calendar.current.date(from: components)!) == self.toString("yyyy-MM-dd")
    }

    func isStartOfYear() -> Bool {
        let components = Calendar.current.dateComponents([.year], from: self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale.current
        print("start of year \(dateFormatter.string(from: Calendar.current.date(from: components)!))")

        return dateFormatter.string(from: Calendar.current.date(from: components)!) == self.toString("yyyy-MM-dd")
    }
}


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
    
}

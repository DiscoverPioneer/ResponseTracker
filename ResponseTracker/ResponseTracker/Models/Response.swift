import Foundation
import RealmSwift

private struct SerializationKeys {
    static let incidentNumber = "incidentNumber"
    static let details = "details"
    static let date = "date"
}

class Response: Object{ //}: NSObject, NSCoding {
    @objc dynamic var incidentNumber: String = ""
    @objc dynamic var details: String = ""
    @objc dynamic var date: Date = Date()

    convenience init(incidentNumber: String, details: String, date: Date) {
        self.init()
        self.incidentNumber = incidentNumber
        self.details = details
        self.date = date
    }

    func toCSV() -> String {
        return incidentNumber + "," + date.toString() + "," + details
    }
}

import Foundation

private struct SerializationKeys {
    static let incidentNumber = "incidentNumber"
    static let details = "details"
    static let date = "date"
}

class Response: NSObject, NSCoding {
    var incidentNumber: String
    var details: String
    var date: Date

    init(incidentNumber: String, details: String, date: Date) {
        self.incidentNumber = incidentNumber
        self.details = details
        self.date = date
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(incidentNumber, forKey: SerializationKeys.incidentNumber)
        aCoder.encode(details, forKey: SerializationKeys.details)
        aCoder.encode(date, forKey: SerializationKeys.date)
    }

    required init?(coder aDecoder: NSCoder) {
        incidentNumber = aDecoder.decodeObject(forKey: SerializationKeys.incidentNumber) as? String ?? ""
        details = aDecoder.decodeObject(forKey: SerializationKeys.details) as? String ?? ""
        date = aDecoder.decodeObject(forKey: SerializationKeys.date) as? Date ?? Date()
    }
}

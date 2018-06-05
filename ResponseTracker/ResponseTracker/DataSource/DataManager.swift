import Foundation
import RealmSwift

enum DataError {
    case alreadyExists
    case errorReadingData
    case errorWritingData
    case errorClearData
    case errorExportingData

    var message: String {
        switch self {
        case .alreadyExists: return "Emergency type already exists"
        case .errorReadingData: return "Error reading data"
        case .errorWritingData: return "Data could not be saved!"
        case .errorClearData: return "Data could not be cleared"
        case .errorExportingData: return "Error exporting data"
        }
    }
}

typealias DataOperationSuccessBlock = (_ success: Bool, _ error: DataError?) -> ()

class DataManager {
    let defaultRealm = try! Realm()

    static let shared = DataManager()
    private var points: Points = Points(currentYear: 0, currentMonth: 0, previousMonth: 0, all: 0)
    private var emergencyTypes: [Emergency] = []
    private var lastResonse: Response?

    init() {
        points = loadPoints()
        emergencyTypes = loadEmergencyTypes()
        lastResonse = loadLastResponse()
    }

    func getPoints() -> Points {
        return points
    }

    func getEmergencyTypes() -> [Emergency] {
        return emergencyTypes
    }

    func getLastResponse() -> Response? {
        return loadLastResponse()
    }

    func add(emergency: Emergency, callback: DataOperationSuccessBlock) {
        do {
            try defaultRealm.write {
                if alreadyExists(newEmergency: emergency){
                    callback(false, DataError.alreadyExists)
                } else {
                    emergencyTypes.append(emergency)
                    defaultRealm.add(emergency)
                    callback(true, nil)
                }
            }
        } catch {
            callback(true, DataError.errorWritingData)
        }
    }

    func add(response: Response, toEmergency emergency: Emergency, callback: DataOperationSuccessBlock) {
        do {
            try defaultRealm.write {
                emergency.add(response: response)
                defaultRealm.add(response)
                points = loadPoints()
                callback(true, nil)
            }
        } catch {
            callback(false, DataError.errorWritingData)
        }
    }

    func remove(response: Response, fromEmergency emergency: Emergency, callback: DataOperationSuccessBlock) {
        do {
            try defaultRealm.write {
                emergency.remove(response: response)
                defaultRealm.delete(response)
                points = loadPoints()
                callback(true, nil)
            }
        } catch {
            callback(false, DataError.errorClearData)
        }
    }

    func update(response: Response, newValue: Response, callback: DataOperationSuccessBlock) {
        do {
            try defaultRealm.write {
                response.date = newValue.date
                response.details = newValue.details
                response.incidentNumber = newValue.incidentNumber
                callback(true, nil)
            }
        } catch {
            callback(false, DataError.errorWritingData)
        }
    }

    func persistData() {
        saveEmergencyTypes(emergencyTypes: emergencyTypes) { (success, error) in }
    }

    func clearAllData(callback: DataOperationSuccessBlock) {
        defaultRealm.beginWrite()
        defaultRealm.deleteAll()
        do {
            try defaultRealm.commitWrite()
            self.emergencyTypes = []
            self.points.clearPoints()
            self.lastResonse = nil
            callback(true, nil)
        } catch {
            callback(false, DataError.errorClearData)
        }
    }

    func manuallyAdd(points: Int) {
        let newPoints: [String: Any] = ["date_added": Date(), "points" : points]
        var totalPreset: [[String: Any]] = getPresetPoints()
        totalPreset.append(newPoints)
        let archevedPoints = NSKeyedArchiver.archivedData(withRootObject: totalPreset)
        UserDefaults.standard.set(archevedPoints, forKey: "preset_points")
        UserDefaults.standard.synchronize()
        self.points = loadPoints()
    }

    func clearPoints() {
        lastClearPoints(date: Date())
        self.points.clearPoints()
    }

    func export() {
        let fileName = "EmergencyResponses.csv"
        let path = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)

        var csv = "Emergency type, Incident number, Date, Details\n"

        for emergency in emergencyTypes {
            csv += emergency.toCSV()
        }

        do {
            try csv.write(to: path, atomically: true, encoding: .utf8)
            AlertFactory.showExportActivity(path: path)
        } catch {
            AlertFactory.showOKAlert(message: DataError.errorExportingData.message)
        }
    }

    //MARK: - Private Methids
    fileprivate func alreadyExists(newEmergency: Emergency) -> Bool {
        return emergencyTypes.filter({ (emergency) -> Bool in
            return emergency.type == newEmergency.type
        }).count != 0
    }

    private func getPresetPoints() -> [[String: Any]] {
        guard let unarchivedPoints = UserDefaults.standard.object(forKey: "preset_points") as? Data,
            let points = NSKeyedUnarchiver.unarchiveObject(with: unarchivedPoints) as? [[String: Any]] else { return [] }
        return points
    }

    private func lastClearPoints(date: Date) {
        UserDefaults.standard.set(date, forKey: "last_point_reset")
        UserDefaults.standard.synchronize()
    }

    private func loadPoints() -> Points {
        var startOfYear = Date().startOfYear()
        var startOfPreviousMonth = Date().startOfPreviousMonth()
        var startOfMonth = Date().startOfMonth()

        var allResponsesCount = 0
        var yearlyResponses = 0
        var monthyResponse = 0
        var previousMonth = 0

        if let lastReset =  UserDefaults.standard.object(forKey: "last_point_reset") as? Date {
            startOfYear = startOfYear > lastReset ? startOfYear : lastReset
            startOfPreviousMonth = startOfPreviousMonth > lastReset ? startOfPreviousMonth : lastReset
            startOfMonth = startOfMonth > lastReset ? startOfMonth : lastReset
        }

        let presetPoints = getPresetPoints()
        for points in presetPoints {
            guard let date = points["date_added"] as? Date,
                let points = points["points"] as? Int else { break }
            if date >= startOfMonth { yearlyResponses += points }
            if date >= startOfMonth { monthyResponse += points }
            if date >= startOfPreviousMonth && date < startOfMonth { previousMonth += points }

            allResponsesCount += points
        }

        let allResponses = defaultRealm.objects(Response.self)
        allResponsesCount += allResponses.count
        yearlyResponses += allResponses.filter("date >= %@", startOfYear).count
        monthyResponse += allResponses.filter("date >=  %@", startOfMonth).count
        previousMonth += allResponses.filter("date >= %@ AND date <= %@", startOfPreviousMonth, startOfMonth).count

        return Points(currentYear: yearlyResponses,
                      currentMonth: monthyResponse,
                      previousMonth: previousMonth,
                      all: allResponsesCount)
    }

    private func loadEmergencyTypes() -> [Emergency] {
        return Array(defaultRealm.objects(Emergency.self))
    }

    private func saveEmergencyTypes(emergencyTypes: [Emergency], callback: DataOperationSuccessBlock) {
        for emergency in emergencyTypes {
            do {
                try defaultRealm.write {
                    defaultRealm.add(emergency)
                }
            } catch {
                callback(false, DataError.errorWritingData)
            }
        }
    }

    private func loadLastResponse() -> Response? {
        return Array(defaultRealm.objects(Response.self)).last
    }
}

import Foundation

enum DataError {
    case alreadyExists
    case errorReadingData
    case errorWritingData
    case errorClearData

    var message: String {
        switch self {
        case .alreadyExists: return "Emergency type already exists"
        case .errorReadingData: return "Error reading data"
        case .errorWritingData: return "Emergency type could not be saved!"
        case .errorClearData: return "Data could not be cleared"
        }
    }
}

typealias SaveDataBlock = (_ success: Bool, _ error: DataError?) -> ()

class EmergencyTypeDataSource {
    private static let fileURL = FileManager.default.urls(for: .documentDirectory,
                                                               in: .userDomainMask).first?.appendingPathComponent("EmergencyTypes")

    class func getEmergencyTypes() -> [Emergency] {
        guard let fileURL = EmergencyTypeDataSource.fileURL else { print("Error"); return [] }
        if let emergencyTypes: [Emergency] = NSKeyedUnarchiver.unarchiveObject(withFile: fileURL.path) as? [Emergency] {
            return emergencyTypes
        }
        return []
    }

    class func saveEmergencyType(emergency: Emergency, callback: SaveDataBlock) {
        guard let fileURL = EmergencyTypeDataSource.fileURL else { callback(false, DataError.errorWritingData); return }
        var emergencyTypes = getEmergencyTypes()
        if !emergencyTypes.contains(where: { (savedEmergency) -> Bool in
            return savedEmergency.type == emergency.type
        }) {
            emergencyTypes.append(emergency)
            let success = NSKeyedArchiver.archiveRootObject(emergencyTypes, toFile: fileURL.path)
            callback(success, success ? nil : DataError.errorWritingData)
        } else {
            callback(false, DataError.alreadyExists)
        }
    }

    class func update(emergency: Emergency) -> Bool {
        guard let fileURL = EmergencyTypeDataSource.fileURL else { print("Error"); return false }
        var emergencyTypes = EmergencyTypeDataSource.getEmergencyTypes()

        if let index = emergencyTypes.index(where: { (oldValue) -> Bool in
            return oldValue.type == emergency.type
        }) {
            emergencyTypes[index] = emergency
            return NSKeyedArchiver.archiveRootObject(emergencyTypes, toFile: fileURL.path)
        } else {
            return false
        }
    }

    class func clearAllData(callback: SaveDataBlock)  {
        guard let fileURL = EmergencyTypeDataSource.fileURL, !getEmergencyTypes().isEmpty else { print("Error"); return }
        do {
            try FileManager.default.removeItem(at: fileURL)
            callback(true, nil)
        } catch {
            print("error \(error.localizedDescription)")
            callback(false, DataError.errorClearData)
        }
    }

    class func save(lastResponse: Response) {
        UserDefaults.standard.set(lastResponse, forKey: "last_response")
        UserDefaults.standard.synchronize()
    }

    class func getLastResponse() -> Response? {
       return UserDefaults.standard.value(forKey: "last_response") as? Response
    }

    class func clearLastResponse() {
        UserDefaults.standard.removeObject(forKey: "last_response")
        UserDefaults.standard.synchronize()
    }
}

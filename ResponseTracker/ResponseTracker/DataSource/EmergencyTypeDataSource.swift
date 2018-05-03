import Foundation

enum DataError {
    case alreadyExists
    case errorReadingData
    case errorWritingData

    var message: String {
        switch self {
        case .alreadyExists: return "Emergency type already exists"
        case .errorReadingData: return "Error reading data"
        case .errorWritingData: return "Emergency type could not be saved!"
        }
    }
}

typealias SaveDataBlock = (_ success: Bool, _ error: DataError?) -> ()

class EmergencyTypeDataSource {
    private static let fileURL = FileManager.default.urls(for: .documentDirectory,
                                                               in: .userDomainMask).first?.appendingPathComponent("EmergencyTypes")

    class func getEmergencyTypes() -> [Call] {
        guard let fileURL = EmergencyTypeDataSource.fileURL else { print("Error"); return [] }
        if let emergencyTypes: [Call] = NSKeyedUnarchiver.unarchiveObject(withFile: fileURL.path) as? [Call] {
            return emergencyTypes
        }
        return []
    }

    class func saveEmergencyType(emergency: Call, callback: SaveDataBlock) {
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

    class func update(emergency: Call) -> Bool {
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
}

import Foundation

enum DateRange {
    case currentMonth
    case previousMonth
    case currentYear
    case all
}

class PointsDataSource {
    
    class func getPoints() -> Points {
        guard let unarchived = UserDefaults.standard.object(forKey:"current_points") as? Data,
            let points = NSKeyedUnarchiver.unarchiveObject(with: unarchived) as? Points
            else {
                return Points(currentYear: 0, currentMonth: 0, previousMonth: 0, all: 0)
        }
        return points
    }

    class func save(points: Points) {
        let archivedPoints = NSKeyedArchiver.archivedData(withRootObject: points)
        UserDefaults.standard.set(archivedPoints, forKey: "current_points")
        UserDefaults.standard.synchronize()
    }

    class func reset(pointsForRange range: DateRange) {
        let currentPoints = getPoints()
        switch range {
        case .all: currentPoints.all = 0
        case .currentMonth: currentPoints.currentMonth = 0
        case .previousMonth: currentPoints.previousMonth = 0
        case .currentYear: currentPoints.currentYear = 0
        }
        save(points: currentPoints)
    }

    class func resetAllPoints() {
        UserDefaults.standard.removeObject(forKey: "current_points")
        UserDefaults.standard.synchronize()
    }

    class func add(points: Int) -> Points {
        let currentPoints = getPoints()
        if points < 0, currentPoints.currentMonth == 0, currentPoints.currentMonth == 0, currentPoints.all == 0 {
            return currentPoints
        }

        currentPoints.currentMonth += points
        currentPoints.currentYear += points
        currentPoints.all += points

        save(points: currentPoints)
        return currentPoints
    }

    class func newMonthPointsTransfer() {
        guard let lastTransfer = UserDefaults.standard.object(forKey: "last_points_transfer") as? String,
                    lastTransfer != Date().toString("yyyy-MM-dd") else { return }

        let currentPoints = getPoints()
        currentPoints.previousMonth = currentPoints.currentMonth
        currentPoints.currentMonth = 0
        save(points: currentPoints)

        UserDefaults.standard.set(Date().toString("yyyy-MM-dd"), forKey: "last_points_transfer")
        UserDefaults.standard.synchronize()
    }

    class func newYearPointsReset() {
        let currentPoints = getPoints()
        currentPoints.currentYear = 0
        save(points: currentPoints)
    }

    class func refreshPointsIfNeeded() {
        if Date().isStartOfMonth() {
            // new month = transfer points to previous month
            PointsDataSource.newMonthPointsTransfer()
        }

        if Date().isStartOfYear() {
            // new year = clear year points
            PointsDataSource.newYearPointsReset()
        }
    }
}

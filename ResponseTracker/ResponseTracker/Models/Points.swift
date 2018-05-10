import Foundation

private struct SerializationKeys {
    static let currentMonth = "current_month"
    static let previousMonth = "previous_month"
    static let currentYear = "current_year"
    static let all = "all_points"
}

class Points: NSObject, NSCoding {
    var currentYear: Int = 0
    var currentMonth: Int = 0
    var previousMonth: Int = 0
    var all: Int = 0

    init(currentYear: Int, currentMonth: Int, previousMonth: Int, all: Int) {
        self.currentYear = currentYear
        self.currentMonth = currentMonth
        self.previousMonth = previousMonth
        self.all = all
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(currentYear, forKey: SerializationKeys.currentYear)
        aCoder.encode(currentMonth, forKey: SerializationKeys.currentMonth)
        aCoder.encode(previousMonth, forKey: SerializationKeys.previousMonth)
        aCoder.encode(all, forKey: SerializationKeys.all)
    }

    required init?(coder aDecoder: NSCoder) {
        currentYear = aDecoder.decodeInteger(forKey: SerializationKeys.currentYear)
        currentMonth = aDecoder.decodeInteger(forKey: SerializationKeys.currentMonth)
        previousMonth = aDecoder.decodeInteger(forKey: SerializationKeys.previousMonth)
        all = aDecoder.decodeInteger(forKey: SerializationKeys.all)
    }

    func increaseCurrent(by points: Int) {
        all += points
        currentMonth += points
        currentYear += points
    }

    func clearPoints() {
        all = 0
        currentYear = 0
        currentMonth = 0
        previousMonth = 0 
    }

    func isEmpty() -> Bool {
        return currentYear == 0 && currentMonth == 0 && all == 0
    }
}


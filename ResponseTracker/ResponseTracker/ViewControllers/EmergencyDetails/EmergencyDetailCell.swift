import Foundation
import UIKit

class EmergencyDetailCell: UITableViewCell {
    static let reuseID = "EmergencyDetailCellIdentifier"

    func update(withResponse response: Response) {
        textLabel?.text = response.incidentNumber
        detailTextLabel?.text = response.date.toString()
    }
}

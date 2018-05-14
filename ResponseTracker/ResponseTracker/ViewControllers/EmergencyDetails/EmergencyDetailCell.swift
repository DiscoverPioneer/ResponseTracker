import Foundation
import UIKit

class EmergencyDetailCell: UITableViewCell {
    static let reuseID = "EmergencyDetailCellIdentifier"
    @IBOutlet weak var incidentNumberLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    func update(withResponse response: Response) {
        incidentNumberLabel?.text = response.incidentNumber
        descriptionLabel?.text = response.date.toString()
    }
}

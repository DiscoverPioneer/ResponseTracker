import Foundation
import UIKit

class EmergencyDetailCell: UITableViewCell {
    static let reuseID = "EmergencyDetailCellIdentifier"
    @IBOutlet weak var incidentNumberLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var strikethroughView: UIView!
    @IBOutlet weak var strikethroughWidthConstraint: NSLayoutConstraint!

    func update(withResponse response: Response) {
        incidentNumberLabel?.text = response.incidentNumber
        descriptionLabel?.text = response.date.toString("MM/dd/yyyy HH:mm a")
    }

    func strikethrough() {
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.strikethroughWidthConstraint.constant = (self?.frame.width ?? 30) - 60
        }
    }

}

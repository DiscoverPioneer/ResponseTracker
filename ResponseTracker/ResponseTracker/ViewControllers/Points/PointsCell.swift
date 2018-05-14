import Foundation
import UIKit

class PointsCell: UITableViewCell {
    static let cellReuseID = "PointsCellResuseIdentifier"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!

    func update(withTitle title: String, details: String) {
        titleLabel.text = title
        detailsLabel.text = details
    }
}

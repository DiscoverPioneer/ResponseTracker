import Foundation
import UIKit

typealias RespondedBtnCallback = (_ button: UIButton, _ emergencyType: String) -> ()

class EmergencyCell: UITableViewCell {

    static let cellIdentifier = "CallTypeCellIdentifier"

    @IBOutlet weak var respondedButton: UIButton!
    @IBOutlet weak var numberOfCallLabel: UILabel!
    @IBOutlet weak var callTypeLabel: UILabel!

    private var respondedCallback: RespondedBtnCallback?
    private var emergency: Emergency?

    func update(withEmergency emergency: Emergency, onRespondedCallback callback: @escaping RespondedBtnCallback) {
        self.emergency = emergency
        self.numberOfCallLabel.text = String(describing: emergency.getPoints().currentMonth)
        self.callTypeLabel.text = emergency.type
        self.respondedCallback = callback
    }

    //MARK: - Actions
    @IBAction func onResponded(_ sender: UIButton) {
        respondedCallback?(sender, emergency?.type ?? "")
    }
}

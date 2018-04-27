import Foundation
import UIKit

typealias RespondedBtnCallback = (_ button: UIButton) -> ()

class CallCell: UITableViewCell {

    static let cellIdentifier = "CallTypeCellIdentifier"

    @IBOutlet weak var respondedButton: UIButton!
    @IBOutlet weak var numberOfCallLabel: UILabel!
    @IBOutlet weak var callTypeLabel: UILabel!

    private var respondedCallback: RespondedBtnCallback?

    func update(withCall call: Call, onRespondedCallback callback: @escaping RespondedBtnCallback) {
        self.numberOfCallLabel.text = call.responsesCount()
        self.callTypeLabel.text = call.type
        self.respondedCallback = callback
    }

    //MARK: - Actions
    @IBAction func onResponded(_ sender: UIButton) {
        respondedCallback?(sender)
    }
}

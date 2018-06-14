import Foundation
import UIKit

class ButtonCell: UITableViewCell {
    static let cellReuseID = "ButtonCellReuseIdentifier"

    @IBOutlet weak var button: UIButton!
    private var onButtonCallback: ((_ button: UIButton) -> ())?
    
    func update(withTitle title: String, onButtonTapped: @escaping (_ button: UIButton) -> ()) {
        button.setTitle(title, for: .normal)
        self.onButtonCallback = onButtonTapped
    }

    @IBAction func onButton(_ sender: UIButton) {
        onButtonCallback?(sender)
    }
}

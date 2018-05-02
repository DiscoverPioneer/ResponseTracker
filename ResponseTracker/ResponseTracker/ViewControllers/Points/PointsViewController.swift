import Foundation
import UIKit

class PointsViewController: UIViewController {
        
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    let sampleData = "Last responeded call \n\(Date().toString()) \n\n year points \n5 \n\n month points \n3 \n\n last monts points \n1"

    override func viewDidLoad() {
        pointsLabel.text = sampleData
    }

    @IBAction func onResetPoints(_ sender: Any) {
        //TODO
    }
}

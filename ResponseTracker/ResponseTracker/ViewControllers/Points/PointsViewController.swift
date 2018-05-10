import Foundation
import UIKit

class PointsViewController: UIViewController {

    static let storyboardID = "PointsDetailsViewController"

    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!

    private var points: Points?
    private var lastResponse: Response?
    private var clearDataCallback: (()->())?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPoints()
    }

    func setupPoints() {
        guard let points = points else { return }
        let response = lastResponse?.date.toString() ?? "No responses yet"
        pointsLabel.text = "Last responeded call \n\(response) \n\n Total Yearly Points \n\(points.currentYear) \n\n This Months Points \n\(points.currentMonth) \n\n Last Months Points \n\(points.previousMonth)"
    }

    func update(withPoints points: Points, lastResponse: Response?, clearDataBlock: @escaping ()->()) {
        self.points = points
        self.lastResponse = lastResponse
        self.clearDataCallback = clearDataBlock
    }

    @IBAction func onResetPoints(_ sender: Any) {
        DataManager.shared.clearPoints()
        points?.clearPoints()
        setupPoints()
    }
    
    @IBAction func addPoints(_ sender: Any) {
        AlertFactory.showAddPointsAlert { [weak self] (points) in
            DataManager.shared.manuallyAdd(points: points)
            self?.points?.increaseCurrent(by: points)
            self?.setupPoints()
        }
    }
    
    @IBAction func onClearData(_ sender: Any) {
        AlertFactory.showOKCancelAlert(message: "This action can not be undone!", onOK: { [weak self] in
            self?.clearDataCallback?()
            self?.lastResponse = nil
            self?.points?.clearPoints()
            self?.setupPoints()
        })

    }
    @IBAction func onExportData(_ sender: Any) {
        DataManager.shared.export()
    }
}

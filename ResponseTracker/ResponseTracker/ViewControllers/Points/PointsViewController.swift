import Foundation
import UIKit

class PointsViewController: UIViewController {

    static let storyboardID = "PointsDetailsViewController"

    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!

    private var points: Points?
    private var lastResponse: Response?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPoints()
    }

    func setupPoints() {
        guard let points = points else { return }
        let response = lastResponse?.date.toString() ?? "No responses yet"
        pointsLabel.text = "Last responeded call \n\(response) \n\n Total Yearly Points \n\(points.currentYear) \n\n This Months Points \n\(points.currentMonth) \n\n Last Months Points \n\(points.previousMonth)"
    }

    func update(withPoints points: Points, lastResponse: Response?) {
        self.points = points
        self.lastResponse = lastResponse
    }

    @IBAction func onResetPoints(_ sender: Any) {
        PointsDataSource.resetAllPoints()
        self.points = Points(currentYear: 0, currentMonth: 0, previousMonth: 0, all: 0)
        setupPoints()
    }
    
    @IBAction func addPoints(_ sender: Any) {
        AlertFactory.showAddPointsAlert { [weak self] (points) in
            self?.points = PointsDataSource.add(points: points)
            self?.setupPoints()
        }
    }
    
    @IBAction func onClearData(_ sender: Any) {
      //TODO
    }
}

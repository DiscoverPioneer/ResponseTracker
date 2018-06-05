import Foundation
import UIKit

class PointsViewController: UIViewController {

    static let storyboardID = "PointsDetailsViewController"
    private var titles = ["Total Yearly Points:", "This Month's Points:", "Last Month's Points:"]

    private var pointStrings: [String] = []

    @IBOutlet weak var pointsTable: UITableView!

    private var points: Points?
    private var clearDataCallback: (()->())?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPoints()
    }

    func setupPoints() {
        guard let points = points else { return }
        pointsTable.dataSource = self
        pointStrings =  [String(describing: points.currentYear),
                        String(describing: points.currentMonth),
                        String(describing: points.previousMonth)]
        pointsTable.reloadData()
    }

    func update(withPoints points: Points, clearDataBlock: @escaping ()->()) {
        self.points = points
        self.clearDataCallback = clearDataBlock
    }

    @IBAction func onMenu(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Add Points", style: .default, handler: { [weak self] (addAction) in
            self?.onAddPoints()
        }))

        actionSheet.addAction(UIAlertAction(title: "Export Points", style: .default, handler: { [weak self] (exportAction) in
            self?.onExportData()
        }))

        actionSheet.addAction(UIAlertAction(title: "Reset Points", style: .destructive, handler: { [weak self]  (resetPointsAction) in
            self?.onResetPoints()
        }))

        actionSheet.addAction(UIAlertAction(title: "Clear All Data", style: .destructive, handler: { [weak self]  (clearDataAction) in
            self?.onClearData()
        }))

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }

    private func onResetPoints() {
        AlertFactory.showOKCancelAlert(message: "This action can not be undone!", onOK: { [weak self] in
            DataManager.shared.clearPoints()
            self?.points?.clearPoints()
            self?.setupPoints()
        })
    }
    
    private func onAddPoints() {
        AlertFactory.showAddPointsAlert { [weak self] (points) in
            DataManager.shared.manuallyAdd(points: points)
            self?.points?.increaseCurrent(by: points)
            self?.setupPoints()
        }
    }
    
    private func onClearData() {
        AlertFactory.showOKCancelAlert(message: "This action can not be undone!", onOK: { [weak self] in
            self?.clearDataCallback?()
            self?.points?.clearPoints()
            self?.setupPoints()
        })
    }
    
   private func onExportData() {
        DataManager.shared.export()
    }
}

extension PointsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PointsCell.cellReuseID, for: indexPath) as! PointsCell
        cell.update(withTitle: titles[indexPath.row], details: pointStrings[indexPath.row])
        return cell
    }
}

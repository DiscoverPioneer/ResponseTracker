import Foundation
import UIKit

private enum ActionType: Int {
    case addPoints
    case exportPoints
    case resetSettings

    var title: String {
        switch self {
        case .addPoints: return "Add Points"
        case .exportPoints: return "Export Points"
        case .resetSettings: return "Reset Settings"
        }
    }
}

private enum ResetType: String {
    case points = "Reset Points"
    case addData = "Clear All Data"
}

class PointsViewController: UIViewController {

    static let storyboardID = "PointsDetailsViewController"
    private var titles = ["Total Yearly Points:", "This Month's Points:", "Last Month's Points:"]
    private var actions: [ActionType] = [.addPoints, . exportPoints, .resetSettings]

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
        pointsTable.delegate = self
        pointStrings =  [String(describing: points.currentYear),
                        String(describing: points.currentMonth),
                        String(describing: points.previousMonth)]
        pointsTable.reloadData()
    }

    func update(withPoints points: Points, clearDataBlock: @escaping ()->()) {
        self.points = points
        self.clearDataCallback = clearDataBlock
    }

    @IBAction func onResetSettings() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

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

    private func handle(action: ActionType) {
        switch action {
        case .addPoints: onAddPoints()
        case .exportPoints: onExportData()
        case .resetSettings: onResetSettings()
        }
    }

    //MARK: Table view helper methods
    fileprivate func numberOfCells(forSection section: Int) -> Int {
        switch section {
        case 0: return titles.count
        case 1: return actions.count
        default: return 0
        }
    }

    fileprivate func cell(forIndexPath index: IndexPath) -> UITableViewCell {
        switch index.section {
        case 0:
            let cell = pointsTable.dequeueReusableCell(withIdentifier: PointsCell.cellReuseID, for: index) as! PointsCell
            cell.update(withTitle: titles[index.row], details: pointStrings[index.row])
            return cell
        default:
            let cell = pointsTable.dequeueReusableCell(withIdentifier: ButtonCell.cellReuseID, for: index) as! ButtonCell
            cell.update(withTitle: actions[index.row].title, onButtonTapped: { [weak self] _ in
                guard let actionType  = ActionType(rawValue: index.row) else { return }
                self?.handle(action: actionType)
            })
            return cell
        }
    }

    fileprivate func height(forSection section: Int) -> CGFloat {
        switch section {
        case 1: return 50
        default: return 0
        }
    }

    fileprivate func header(forSection section: Int) -> UIView {
        let header = UIView()
        header.backgroundColor = .white
        header.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)

        let topSeparator = UIView()
        topSeparator.backgroundColor = UIColor(red: 226.0/255.0, green: 219.0/255.0, blue: 190.0/255.0, alpha: 0.7)
        topSeparator.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 0.5)
        header.addSubview(topSeparator)

        let bottomSeparator = UIView()
        bottomSeparator.backgroundColor = UIColor(red: 226.0/255.0, green: 219.0/255.0, blue: 190.0/255.0, alpha: 0.7)
        bottomSeparator.frame = CGRect(x: 0, y: 49, width: view.frame.width, height: 0.5)
        header.addSubview(bottomSeparator)

        return header
    }
}

//MARK: Table view delegate
extension PointsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfCells(forSection: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cell(forIndexPath: indexPath)
    }
}

extension PointsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return height(forSection: section)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return header(forSection: section)
    }
}

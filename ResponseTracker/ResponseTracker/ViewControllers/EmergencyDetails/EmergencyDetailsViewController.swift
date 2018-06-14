import Foundation
import UIKit

class EmergencyDetailsViewController: UIViewController {
    static let storyboardID = "EmergencyCallDetailsViewController"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pointsLabel: UILabel!

    private var emergencyCall: Emergency?
    private var responseRemovedBlock: ResponseAddCallback?
    private var responseEditBlock: ResponseEditCallback?
    private var showEmptyData: Bool = false
    private var deletedItems: [Response] = []
    private var points: Points?

    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self

        title = emergencyCall?.type ?? ""
        showEmptyData = emergencyCall?.responsesCount() == 0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
        setupPoints()
    }

    func update(withEmergencyCall call: Emergency,
                repsonseAddedCallback: ResponseAddCallback?,
                responseEditBlock: ResponseEditCallback?) {

        self.emergencyCall = call
        self.responseRemovedBlock = repsonseAddedCallback
        self.responseEditBlock = responseEditBlock
    }

    func getEmergencyResponses() -> [Response] {
        guard let responses = emergencyCall?.responses else { return [] }
        return Array(responses)
    }

    private func setupPoints() {
        self.points = emergencyCall?.getPoints()
        self.pointsLabel.text = "Total Monthly Points: \(points?.currentMonth ?? 0) \nTotal Yearly Points: \(points?.currentYear ?? 0)"

    }

    //MARK: - Actions
    @IBAction func onDelete(_ sender: UIBarButtonItem) {
        guard  let emergency = emergencyCall else { return }
        AlertFactory.showOKCancelAlert(message: "Are you sure you want to delete this emergency type?") {
            DataManager.shared.remove(emergency: emergency, callback: { [weak self] (success, error) in
                if error != nil {
                    AlertFactory.showOKAlert(message: error?.message ?? "")
                } else {
                    self?.navigationController?.popViewController(animated: true)
                }
            })
        }
    }

    @IBAction func onEdit(_ sender: UIBarButtonItem) {
        guard let emergency = emergencyCall else { return }
        AlertFactory.showEditEmergencyTypeAlert(title: "Edit emergency type", text: emergency.type) { (newName) in
            DataManager.shared.update(emergency: emergency, newName: newName, callback: { [weak self] (success, error) in
                if error != nil {
                    AlertFactory.showOKAlert(message: error?.message ?? "")
                } else {
                    self?.title = newName
                }
            })
        }
    }
}

extension EmergencyDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showEmptyData ? 1 : getEmergencyResponses().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if showEmptyData {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ResponsesEmptyDataCell", for: indexPath) as UITableViewCell
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: EmergencyDetailCell.reuseID, for: indexPath) as! EmergencyDetailCell
        cell.update(withResponse: getEmergencyResponses()[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let responseDetailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: ResponseDetailsViewController.storyboardID) as? ResponseDetailsViewController,
            let emergencyType = emergencyCall else { return }
        self.navigationController?.pushViewController(responseDetailsVC, animated: true)
        responseDetailsVC.update(withEmergencyType: emergencyType,
                                 response: getEmergencyResponses()[indexPath.row],
                                 responseAddedBlock: responseRemovedBlock,
                                 resposeChangedBlock: responseEditBlock)
    }
}

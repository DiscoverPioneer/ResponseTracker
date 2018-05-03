import Foundation
import UIKit

class EmergencyDetailsViewController: UIViewController {
    static let storyboardID = "EmergencyCallDetailsViewController"
    
    @IBOutlet weak var tableView: UITableView!
    private var emergencyCall: Emergency?

    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none

        title = emergencyCall?.type ?? ""
        handleEmptyDataIfNeeded()
    }

    private func handleEmptyDataIfNeeded() {
        if emergencyCall?.responses?.isEmpty ?? true {
            let emptyDataLabel = UILabel()
            emptyDataLabel.text = "\(emergencyCall?.type ?? "") does not have any responses yet. Press the Responded button to add some."
            emptyDataLabel.textAlignment = .center
            emptyDataLabel.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
            emptyDataLabel.numberOfLines = 0
            tableView.backgroundView = emptyDataLabel
        } else {
            tableView.backgroundView = nil
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }

    func update(withEmergencyCall call: Emergency) {
        self.emergencyCall = call
    }

    func getEmergencyResponses() -> [Response] {
        return emergencyCall?.responses ?? []
    }
}

extension EmergencyDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getEmergencyResponses().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EmergencyDetailCell.reuseID, for: indexPath) as! EmergencyDetailCell
        cell.update(withResponse: getEmergencyResponses()[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let responseDetailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: ResponseDetailsViewController.storyboardID) as? ResponseDetailsViewController,
            let emergencyType = emergencyCall else { return }
        self.navigationController?.pushViewController(responseDetailsVC, animated: true)
        responseDetailsVC.update(withEmergencyType: emergencyType,
                                 response: getEmergencyResponses()[indexPath.row])
    }
}

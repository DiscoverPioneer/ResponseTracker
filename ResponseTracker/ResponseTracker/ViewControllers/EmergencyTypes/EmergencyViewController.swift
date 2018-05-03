import UIKit

class EmergencyViewController: UIViewController {
    @IBOutlet weak var callsTableView: UITableView!

    var emergencyTypes: [Emergency] = EmergencyTypeDataSource.getEmergencyTypes()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        callsTableView.reloadData()
        handleEmptyDataIfNeeded()
    }

    private func setupTableView() {
        callsTableView.delegate = self
        callsTableView.dataSource = self
        handleEmptyDataIfNeeded()

        let header = UILabel()
        header.numberOfLines = 0
        header.text = "Total Monthly Points: 3\nTotal Yearly Points: 14"
        header.textAlignment = .center
        header.frame = CGRect(x: 0, y: 0, width: view.frame.width - 20, height: 50)
        callsTableView.tableHeaderView = header
    }

    func getCalls() -> [Emergency] {
        return emergencyTypes
    }

    private func handleEmptyDataIfNeeded() {
        if emergencyTypes.isEmpty {
            let emptyDataLabel = UILabel()
            emptyDataLabel.text = "Emergency calls have not been added yet. Press the Add Call button to add some."
            emptyDataLabel.textAlignment = .center
            emptyDataLabel.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
            emptyDataLabel.numberOfLines = 0
            callsTableView.backgroundView = emptyDataLabel
        } else {
            callsTableView.backgroundView = nil
        }
    }

    //MARK: - Navigation Bar Actions
    func onResponded(emergencyType: String, index: Int) {
        AlertFactory.showOKCancelAlert(message: "Confirm you responded to \(emergencyType)") { [weak self] in
            guard let responseDetailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: ResponseDetailsViewController.storyboardID) as? ResponseDetailsViewController,
                let emergencyType = self?.emergencyTypes[index] else { return }
            self?.navigationController?.pushViewController(responseDetailsVC, animated: true)
            responseDetailsVC.update(withEmergencyType: emergencyType)
        }
    }

    @IBAction func onAddCall(_ sender: Any) {
        AlertFactory.showAddEmergencyTypeAlert { (emergencyType) in
            let newEmergencyType = Emergency(type: emergencyType, responses: [])
            EmergencyTypeDataSource.saveEmergencyType(emergency: newEmergencyType, callback: { [weak self] (success, error) in
                if error != nil {
                    AlertFactory.showOKAlert(message: error!.message)
                } else {
                    self?.emergencyTypes.append(newEmergencyType)
                    self?.callsTableView.reloadData()
                    self?.handleEmptyDataIfNeeded()
                }
            })
        }
    }
}

extension EmergencyViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getCalls().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EmergencyCell.cellIdentifier, for: indexPath) as! EmergencyCell
        cell.update(withEmergency: emergencyTypes[indexPath.row]) { [weak self] (_, emergencyType) in
            self?.onResponded(emergencyType: emergencyType, index: indexPath.row)
        }
        return cell 
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let emergencyCallVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: EmergencyDetailsViewController.storyboardID) as? EmergencyDetailsViewController else { return }
        self.navigationController?.pushViewController(emergencyCallVC, animated: true)
        emergencyCallVC.update(withEmergencyCall: emergencyTypes[indexPath.row])
    }
}


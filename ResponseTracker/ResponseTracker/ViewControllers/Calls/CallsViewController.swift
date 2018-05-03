import UIKit

class CallsViewController: UIViewController {
    @IBOutlet weak var callsTableView: UITableView!

    var calls: [Call] = EmergencyTypeDataSource.getEmergencyTypes() //CallsDataProvider.getCalls()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        callsTableView.reloadData()
    }

    func setupTableView() {
        callsTableView.delegate = self
        callsTableView.dataSource = self

        let header = UILabel()
        header.numberOfLines = 0
        header.text = "Total Monthly Points: 3\nTotal Yearly Points: 14"
        header.textAlignment = .center
        header.frame = CGRect(x: 0, y: 0, width: view.frame.width - 20, height: 50)
        callsTableView.tableHeaderView = header
    }

    func getCalls() -> [Call] {
        return calls
    }

    //MARK: - Navigation Bar Actions
    func onResponded(emergencyType: String, index: Int) {
        AlertFactory.showOKCancelAlert(message: "Confirm you responded to \(emergencyType)") { [weak self] in
            guard let responseDetailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: ResponseDetailsViewController.storyboardID) as? ResponseDetailsViewController,
                let emergencyType = self?.calls[index] else { return }
            self?.navigationController?.pushViewController(responseDetailsVC, animated: true)
            responseDetailsVC.update(withEmergencyType: emergencyType)
        }
    }

    @IBAction func onMyPoints(_ sender: Any) {

    }

    @IBAction func onAddCall(_ sender: Any) {
        AlertFactory.showAddEmergencyTypeAlert { (emergencyType) in
            let newEmergencyType = Call(type: emergencyType, responses: [])
            EmergencyTypeDataSource.saveEmergencyType(emergency: newEmergencyType, callback: { [weak self] (success, error) in
                if error != nil {
                    AlertFactory.showOKAlert(message: error!.message)
                } else {
                    self?.calls.append(newEmergencyType)
                    self?.callsTableView.reloadData()
                }
            })
        }
    }
}

extension CallsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getCalls().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CallCell.cellIdentifier, for: indexPath) as! CallCell
        cell.update(withCall: calls[indexPath.row]) { [weak self] (_, emergencyType) in
            self?.onResponded(emergencyType: emergencyType, index: indexPath.row)
        }
        return cell 
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let emergencyCallVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: EmergencyDetailsViewController.storyboardID) as? EmergencyDetailsViewController else { return }
        self.navigationController?.pushViewController(emergencyCallVC, animated: true)
        emergencyCallVC.update(withEmergencyCall: calls[indexPath.row])
    }
}


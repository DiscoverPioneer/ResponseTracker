import UIKit

class EmergencyViewController: UIViewController {
    @IBOutlet weak var callsTableView: UITableView!
    private var pointsLabel = UILabel()

    var emergencyTypes: [Emergency] = []
    var points: Points = Points(currentYear: 0, currentMonth: 0, previousMonth: 0, all: 0)
    var lastResponse: Response?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
        setupPoints()
        callsTableView.reloadData()
        handleEmptyDataIfNeeded()
    }

    private func loadData() {
        points = DataManager.shared.getPoints()
        emergencyTypes = DataManager.shared.getEmergencyTypes()
        lastResponse = DataManager.shared.getLastResponse()
    }

    private func setupTableView() {
        callsTableView.delegate = self
        callsTableView.dataSource = self
        handleEmptyDataIfNeeded()

        pointsLabel.numberOfLines = 0
        pointsLabel.textAlignment = .center
        pointsLabel.frame = CGRect(x: 0, y: 0, width: view.frame.width - 20, height: 50)
        callsTableView.tableHeaderView = pointsLabel
    }

    private func setupPoints() {
        pointsLabel.text = "Total Monthly Points: \(points.currentMonth)\nTotal Yearly Points: \(points.currentYear)"
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

    private func showResponseDetails(forEmergency emergency: Emergency) {
        guard let responseDetailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: ResponseDetailsViewController.storyboardID) as? ResponseDetailsViewController else { return }
        self.navigationController?.pushViewController(responseDetailsVC, animated: true)
        responseDetailsVC.update(withEmergencyType: emergency,
                                 responseAddedBlock: { [weak self] (response) in
                                    self?.handleNew(response: response, toEmergency: emergency)
                                    self?.setupPoints()
            },
                                 resposeChangedBlock: nil)
    }

    private func addEmptyResponse(forEmergency emergency: Emergency) {
        let response = Response(incidentNumber: "", details: "", date: Date())
        handleNew(response: response, toEmergency: emergency)
    }

    private func handleNew(response: Response, toEmergency emergency: Emergency) {
        DataManager.shared.add(response: response, toEmergency: emergency)
        callsTableView.reloadData()
        lastResponse = response
        loadData()
        setupPoints()
    }

    func handleRemoved(response: Response, fromEmergency emergency: Emergency ) {
        DataManager.shared.remove(response: response, fromEmergency: emergency)
        callsTableView.reloadData()
        loadData()
        setupPoints()
    }

    func handleChanged(response: Response, newValue: Response) {
        DataManager.shared.update(response: response, newValue: newValue)
    }

    //MARK: - Navigation Bar Actions
    func onResponded(index: Int) {
        let emergency = emergencyTypes[index]
        AlertFactory.showOKCancelAlert(message: "Confirm you responded to \(emergency.type)") { [weak self] in
            AlertFactory.showDetailsAlert(message: "You responded to \(emergency.type)", onDone: { [weak self] in
                self?.addEmptyResponse(forEmergency: emergency)
                }, onDetails: { [weak self] in
                    self?.showResponseDetails(forEmergency: emergency)
            })
        }
    }

    @IBAction func onAddCall(_ sender: Any) {
        AlertFactory.showAddEmergencyTypeAlert { [weak self] (emergencyType) in
            let newEmergencyType = Emergency(type: emergencyType, responses: [])
            DataManager.shared.add(emergency: newEmergencyType)
            self?.emergencyTypes.append(newEmergencyType)
            self?.callsTableView.reloadData()
            self?.handleEmptyDataIfNeeded()
        }
    }

    @IBAction func onShowPoints(_ sender: Any) {
        guard let pointsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: PointsViewController.storyboardID) as? PointsViewController else { return }
        pointsVC.update(withPoints: points, lastResponse: lastResponse, clearDataBlock: {
            DataManager.shared.clearAllData(callback: { [weak self] (success, error)  in
                if error != nil {
                    AlertFactory.showOKAlert(message: error!.message)
                } else {
                    AlertFactory.showOKAlert(message: "All data was successfully removed")
                    self?.loadData()
                    self?.callsTableView.reloadData()
                    self?.setupPoints()
                }
            })
        })
        navigationController?.pushViewController(pointsVC, animated: true)
    }
}

extension EmergencyViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getCalls().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EmergencyCell.cellIdentifier, for: indexPath) as! EmergencyCell
        cell.update(withEmergency: emergencyTypes[indexPath.row]) { [weak self] (_, emergencyType) in
            self?.onResponded(index: indexPath.row)
        }
        return cell 
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let emergencyCallVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:
            EmergencyDetailsViewController.storyboardID) as? EmergencyDetailsViewController else { return }
        self.navigationController?.pushViewController(emergencyCallVC, animated: true)
        emergencyCallVC.update(withEmergencyCall: emergencyTypes[indexPath.row],
                               repsonseAddedCallback: { [unowned self] (response) in
                                self.handleRemoved(response: response, fromEmergency: self.emergencyTypes[indexPath.row])
            },
                               responseEditBlock: { [unowned self] (response, newValue) in
                                self.handleChanged(response: response, newValue: newValue)
        })
    }
}


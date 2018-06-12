import UIKit

class EmergencyViewController: UIViewController {
    @IBOutlet weak var callsTableView: UITableView!
    @IBOutlet weak var pointsLabel: UILabel!
    
    var emergencyTypes: [Emergency] = []
    var points: Points = Points(currentYear: 0, currentMonth: 0, previousMonth: 0, all: 0)
    var showEmptyData: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadData()
    }

    private func setupNavigationBar() {
        var colors = [UIColor]()
        colors.append(UIColor(red: 255/255, green: 27/255, blue: 28/255, alpha: 1))
        colors.append(UIColor(red: 255/255, green: 127/255, blue: 17/255, alpha: 1))
        navigationController?.navigationBar.setGradientBackground(colors: colors)
    }

    private func loadData() {
        points = DataManager.shared.getPoints()
        emergencyTypes = DataManager.shared.getEmergencyTypes()
        showEmptyData = emergencyTypes.count == 0
    }

    private func reloadData() {
        loadData()
        callsTableView.reloadData()
        setupPoints()
    }

    private func setupTableView() {
        callsTableView.delegate = self
        callsTableView.dataSource = self
    }

    func getCalls() -> [Emergency] {
        return emergencyTypes
    }

    private func setupPoints() {
        pointsLabel.text = "Total Monthly Points: \(points.currentMonth)\nTotal Yearly Points: \(points.currentYear)"
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
        DataManager.shared.add(response: response, toEmergency: emergency, callback: { [weak self] (success, error) in
            if error != nil {
                AlertFactory.showOKAlert(message: error!.message)
            } else {
                self?.reloadData()
            }
        })
    }

    func handleRemoved(response: Response, fromEmergency emergency: Emergency ) {
        DataManager.shared.remove(response: response, fromEmergency: emergency, callback: { [weak self] (success, error) in
            if error != nil {
                AlertFactory.showOKAlert(message: error!.message)
            } else {
                self?.reloadData()
            }
        })
    }

    func handleChanged(response: Response, newValue: Response) {
        DataManager.shared.update(response: response, newValue: newValue, callback: { (success, error) in
            if error != nil {
                AlertFactory.showOKAlert(message: error!.message)
            }
        })
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
        AlertFactory.showAddEmergencyTypeAlert(title: "Add emergeny type") { [weak self] (emergencyType) in
            let newEmergencyType = Emergency(type: emergencyType, responses: [])
            DataManager.shared.add(emergency: newEmergencyType, callback: { [weak self] (success, error) in
                if error != nil {
                    AlertFactory.showOKAlert(message: error!.message)
                } else {
                    self?.reloadData()
                }
            })
        }
    }

    @IBAction func onShowPoints(_ sender: UIBarButtonItem) {
        guard let pointsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: PointsViewController.storyboardID) as? PointsViewController else { return }
        pointsVC.update(withPoints: points, clearDataBlock: {
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
        return showEmptyData ? 1 : getCalls().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if showEmptyData {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EmergencyEmptyDataCell", for: indexPath) as UITableViewCell
            return cell
        }
        
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


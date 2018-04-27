import UIKit

class CallsViewController: UIViewController {
    @IBOutlet weak var callsTableView: UITableView!

    var calls: [Call] = CallsDataProvider.getCalls()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
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
    func onResponded(emergencyType: String) {
        AlertFactory.showOKCancelAlert(message: "Confirm you responded to \(emergencyType)") {
            //TODO: add response
        }
    }

    @IBAction func onMyPoints(_ sender: Any) {

    }

    @IBAction func onAddCall(_ sender: Any) {
        AlertFactory.showAddEmergencyTypeAlert { (emergencyType) in
            //TODO: Add new emerency type
            print("New emergency type \(emergencyType)")
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
            self?.onResponded(emergencyType: emergencyType)
        }
        return cell 
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}


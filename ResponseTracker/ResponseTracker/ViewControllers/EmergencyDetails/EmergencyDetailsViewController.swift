import Foundation
import UIKit

class EmergencyDetailsViewController: UIViewController {
    static let storyboardID = "EmergencyCallDetailsViewController"
    
    @IBOutlet weak var tableView: UITableView!
    private var emergencyCall: Emergency?
    private var responseAddedBlock: ResponseAddCallback?
    private var responseEditBlock: ResponseEditCallback?

    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none

        title = emergencyCall?.type ?? ""
        handleEmptyDataIfNeeded()
        setupEditButton()
    }

    private func handleEmptyDataIfNeeded() {
        if emergencyCall?.responses.isEmpty ?? true {
            let emptyDataLabel = UILabel()
            emptyDataLabel.text = "\(emergencyCall?.type ?? "") does not have any responses yet."
            emptyDataLabel.textAlignment = .center
            emptyDataLabel.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
            emptyDataLabel.numberOfLines = 0
            tableView.backgroundView = emptyDataLabel
        } else {
            tableView.backgroundView = nil
        }
    }

    private func setupEditButton() {
        if emergencyCall?.responsesCount() == 0 {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
        handleEmptyDataIfNeeded()
    }

    func update(withEmergencyCall call: Emergency,
                repsonseAddedCallback: ResponseAddCallback?,
                responseEditBlock: ResponseEditCallback?) {
        self.emergencyCall = call
        self.responseAddedBlock = repsonseAddedCallback
        self.responseEditBlock = responseEditBlock
    }

    func getEmergencyResponses() -> [Response] {
        guard let responses = emergencyCall?.responses else { return [] }
        return Array(responses)
    }

    func removeItem(atIndex index: IndexPath?) {
        AlertFactory.showOKCancelAlert(message: "Are you sure?") { [weak self] in
            guard let emergency = self?.emergencyCall, let index = index else { return }
            self?.responseAddedBlock?(emergency.responses[index.row])
            self?.tableView.deleteRows(at: [index], with: .left)
            self?.setupEditButton()
            self?.handleEmptyDataIfNeeded()
        }
    }

    //MARK: - Actions
    @IBAction func onEdit(_ sender: UIBarButtonItem) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        navigationItem.rightBarButtonItem?.title = tableView.isEditing ? "Done" : "Edit"
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
                                 response: getEmergencyResponses()[indexPath.row],
                                 responseAddedBlock: responseAddedBlock,
                                 resposeChangedBlock: responseEditBlock)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard let emergency = emergencyCall, editingStyle == .delete else { return }
        removeItem(atIndex: indexPath)
    }
}

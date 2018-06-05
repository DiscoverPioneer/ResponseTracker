import Foundation
import UIKit

class EmergencyDetailsViewController: UIViewController {
    static let storyboardID = "EmergencyCallDetailsViewController"
    
    @IBOutlet weak var tableView: UITableView!
    private var emergencyCall: Emergency?
    private var responseAddedBlock: ResponseAddCallback?
    private var responseEditBlock: ResponseEditCallback?
    private var showEmptyData: Bool = false

    private var deletedItems: [Response] = []

    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self

        title = emergencyCall?.type ?? ""
        showEmptyData = emergencyCall?.responsesCount() == 0
        setupEditButton()
        setupBackButton()
    }

    private func setupEditButton() {
        if emergencyCall?.responsesCount() == 0 {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }

    private func setupBackButton() {
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "back_icon")
        let backButton = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(onBack(_:)))
        backButton.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 17)], for: .normal)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(onBack(_:)))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
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
            guard let emergency = self?.emergencyCall,
                let index = index,
                let cell = self?.tableView.cellForRow(at: index) as? EmergencyDetailCell else { return }

            cell.strikethrough()
            cell.setEditing(false, animated: true)
            cell.isUserInteractionEnabled = false
            self?.deletedItems.append(emergency.responses[index.row])
            self?.setupEditButton()
        }
    }

    //MARK: - Actions
    @IBAction func onEdit(_ sender: UIBarButtonItem) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        navigationItem.rightBarButtonItem?.title = tableView.isEditing ? "Done" : "Edit"
    }

    @objc private func onBack(_ sender: UIBarButtonItem) {
        for item in deletedItems {
            responseAddedBlock?(item)
        }

        navigationController?.popViewController(animated: true)
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
                                 responseAddedBlock: responseAddedBlock,
                                 resposeChangedBlock: responseEditBlock)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard let _ = emergencyCall, editingStyle == .delete else { return }
        removeItem(atIndex: indexPath)
    }
}

import Foundation
import UIKit

class ResponseDetailsViewController: UIViewController {

    static let storyboardID = "ResponseDetailsViewController"

    @IBOutlet weak var incidentNumber: UITextField!
    @IBOutlet weak var incidentDetails: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var incidentDate: UILabel!
    @IBOutlet weak var emergencyType: UILabel!

    private var emergency: Emergency?
    private var response: Response?
    private var editResponse: Response?
    private var editMode: Bool = false

    override func viewDidLoad() {
        setupViews()
    }

    func update(withEmergencyType emergencyType: Emergency, response: Response? = nil) {
        self.editMode = response != nil
        title = editMode ? "Edit response" : "Add response"
        editResponse = Response(incidentNumber: response?.incidentNumber  ?? "",
                                              details: response?.details ?? "",
                                              date: response?.date ?? Date())
        self.response = response ?? Response(incidentNumber: "", details: "", date: Date())
        self.emergency = emergencyType
    }

    func setupViews() {
        emergencyType.text = emergency?.type ?? ""

        incidentNumber.delegate = self
        incidentNumber.text = response?.incidentNumber

        incidentDate.text = response?.date.toString()

        incidentDetails.delegate = self
        incidentDetails.text = response?.details
        incidentDetails.layer.borderColor = UIColor.lightGray.cgColor

        let accessory = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(onDoneButton(_:)))
        accessory.items = [doneButton]
        incidentDetails.inputAccessoryView = accessory
    }

    //MARK: - Actions
    @IBAction func onSave(_ sender: Any) {
        navigationController?.popViewController(animated: true)

        guard let emergency = emergency, let editResponse = editResponse else { return }
        view.endEditing(true)
        if !editMode {
            emergency.add(response: editResponse)
        } else {
            response?.incidentNumber = editResponse.incidentNumber
            response?.details = editResponse.details
            response?.date = editResponse.date
        }

        _ = EmergencyTypeDataSource.update(emergency: emergency)

    }

    @IBAction func onDatePicker(_ datePicker: UIDatePicker) {
        incidentDate.text = datePicker.date.toString()
        editResponse?.date = datePicker.date
    }

    @objc func onDoneButton(_ button: UIButton) {
        incidentDetails.resignFirstResponder()
    }
}

extension ResponseDetailsViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        editResponse?.incidentNumber = textField.text ?? ""
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}

extension ResponseDetailsViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        editResponse?.details = textView.text
    }
}


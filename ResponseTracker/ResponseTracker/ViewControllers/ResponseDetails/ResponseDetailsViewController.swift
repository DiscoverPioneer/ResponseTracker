import Foundation
import UIKit

typealias ResponseAddCallback = (_ newResponse: Response) -> ()
typealias ResponseEditCallback = (_ response: Response, _ newValue: Response) -> ()

class ResponseDetailsViewController: UIViewController {

    static let storyboardID = "ResponseDetailsViewController"
    private let kDatePickerHeight: CGFloat = 216

    @IBOutlet weak var incidentNumber: UITextField!
    @IBOutlet weak var incidentDetails: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var incidentDate: UILabel!
    @IBOutlet weak var emergencyType: UILabel!
    @IBOutlet weak var datePickerHeight: NSLayoutConstraint!
    @IBOutlet weak var changeDate: UIButton!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!

    private var emergency: Emergency?
    private var response: Response?
    private var editResponse: Response?
    private var isEditMode: Bool = false

    private var responseChangedCallback: ResponseEditCallback?
    private var responseAddedCallback: ResponseAddCallback?

    override func viewDidLoad() {
        setupViews()
    }

    func update(withEmergencyType emergencyType: Emergency,
                response: Response? = nil,
                responseAddedBlock: (ResponseAddCallback)?,
                resposeChangedBlock: (ResponseEditCallback)?) {
        self.isEditMode = response != nil
        title = isEditMode ? "Edit response" : "Add response"
        editResponse = Response(incidentNumber: response?.incidentNumber  ?? "",
                                              details: response?.details ?? "",
                                              date: response?.date ?? Date())
        self.response = response ?? Response(incidentNumber: "", details: "", date: Date())
        self.emergency = emergencyType
        self.responseAddedCallback = responseAddedBlock
        self.responseChangedCallback = resposeChangedBlock
    }

    func setupViews() {
        let navItems: [UIBarButtonItem] = isEditMode ? [saveButton, deleteButton] : [saveButton]
        navigationItem.setRightBarButtonItems(navItems, animated: false)
        setupChangeDate(showPicker: false)

        datePickerHeight.constant = 0
        emergencyType.text = emergency?.type ?? ""

        incidentNumber.delegate = self
        incidentNumber.text = response?.incidentNumber
        incidentNumber.layer.borderColor = UIColor.lightGray.cgColor

        incidentDate.text = response?.date.toString("MM/dd/yyyy HH:mm a")

        incidentDetails.delegate = self
        incidentDetails.text = response?.details
        incidentDetails.layer.borderColor = UIColor.lightGray.cgColor

        let accessory = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(onDoneButton(_:)))
        accessory.items = [doneButton]
        incidentDetails.inputAccessoryView = accessory
    }

    private func setupChangeDate(showPicker: Bool) {
        let pickerAlpha: CGFloat = showPicker ? 1 : 0
        let buttonAlpha: CGFloat = showPicker ? 0 : 1
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.datePickerHeight.constant = showPicker ? self?.kDatePickerHeight ?? 0 : 0
            self?.changeDate.alpha = buttonAlpha
            self?.datePicker.alpha = pickerAlpha
            self?.view.layoutIfNeeded()
        }
    }

    //MARK: - Actions
    @IBAction func onSave(_ sender: Any) {
        navigationController?.popViewController(animated: true)

        guard let editResponse = editResponse else { return }
        view.endEditing(true)
        if !isEditMode {
            responseAddedCallback?(editResponse)
        } else {
            guard let response = response else { return }
            responseChangedCallback?(response, editResponse)
        }
    }

    @IBAction func onDatePicker(_ datePicker: UIDatePicker) {
        editResponse?.date = datePicker.date
        UIView.transition(with: incidentDate,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: { [weak self] in
                            self?.incidentDate.text = datePicker.date.toString("MM/dd/yyyy HH:mm a")
            }, completion: nil)
        setupChangeDate(showPicker: false)
    }

    @objc func onDoneButton(_ button: UIButton) {
        incidentDetails.resignFirstResponder()
    }

    @IBAction func onChangeDate(_ sender: UIButton) {
        setupChangeDate(showPicker: datePickerHeight.constant == 0)
    }

    @IBAction func onDelete(_ sender: UIButton) {
        AlertFactory.showOKCancelAlert(message: "Are you sure you want to delete this response?") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
            guard let response = self?.response else { return }
            self?.responseAddedCallback?(response)
        }
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


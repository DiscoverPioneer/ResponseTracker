import Foundation
import UIKit

class ResponseDetailsViewController: UIViewController {

    static let storyboardID = "ResponseDetailsViewController"

    @IBOutlet weak var incidentNumber: UITextField!
    @IBOutlet weak var incidentDetails: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var incidentDate: UILabel!

    private var response = Response(incidentNumber: "", details: "", date: Date())

    override func viewDidLoad() {
        setupViews()
    }

    func update(withResponse response: Response) {
        self.response = response
    }

    func setupViews() {
        incidentNumber.delegate = self
        incidentNumber.text = response.incidentNumber

        incidentDate.text = response.date.toString()

        incidentDetails.delegate = self
        incidentDetails.text = response.details
        incidentDetails.layer.borderColor = UIColor.lightGray.cgColor

        let accessory = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(onDoneButton(_:)))
        accessory.items = [doneButton]
        incidentDetails.inputAccessoryView = accessory
    }

    //MARK: - Actions
    @IBAction func onSave(_ sender: Any) {
        view.endEditing(true)
        //TODO
    }

    @IBAction func onDatePicker(_ datePicker: UIDatePicker) {
        incidentDate.text = datePicker.date.toString()
        response.date = datePicker.date
    }

    @objc func onDoneButton(_ button: UIButton) {
        incidentDetails.resignFirstResponder()
    }
}

extension ResponseDetailsViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        response.incidentNumber = textField.text ?? "" 
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}

extension ResponseDetailsViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        response.details = textView.text
    }
}


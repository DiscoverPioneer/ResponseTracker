import Foundation
import UIKit

typealias AlertCallback = ()-> ()

class AlertFactory {
    class func showOKAlert(message: String, callback: AlertCallback? = nil) {
        let okButton = okAction(callback)
        showAlert(nil, message: message, actions: [okButton])
    }

    class func showOKCancelAlert(message: String, onOK okCallback: @escaping AlertCallback) {
        let okButton = okAction { okCallback() }
        let cancelButton = cancelAction(nil)
        showAlert(nil, message: message, actions: [okButton, cancelButton])
    }

    class func showDetailsAlert(message: String,
                                onDone doneCallback: @escaping AlertCallback,
                                onDetails detailsCallback: @escaping AlertCallback) {
        let doneButton = UIAlertAction(title: "Done", style: .default) { (alertAction) in
            doneCallback()
        }
        let detailsButton = UIAlertAction(title: "Details", style: .default) { (alertAction) in
            detailsCallback()
        }
        showAlert(nil, message: message, actions: [doneButton, detailsButton])
    }

    class func showAddEmergencyTypeAlert(title: String, onOK okCallback: @escaping (_ emergencyType: String) -> ()) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { (textField) in
            textField.autocapitalizationType = .allCharacters
        })
        
        let okButton = okAction {
            if alertController.textFields?[0].text?.isEmpty ?? true {
                showOKAlert(message: "Emergency type can not be empty!")
            } else {
                okCallback(alertController.textFields?[0].text ?? "")
            }
        }

        let cancelButton = cancelAction(nil)

        alertController.addAction(okButton)
        alertController.addAction(cancelButton)
        present(alert:alertController)
    }

    class func showEditEmergencyTypeAlert(title: String, text: String? = "", onOK okCallback: @escaping (_ emergencyType: String) -> ()) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { (textField) in
            textField.autocapitalizationType = .allCharacters
            textField.text = text
        })

        let okButton = okAction {
            if alertController.textFields?[0].text?.isEmpty ?? true {
                return
            } else {
                okCallback(alertController.textFields?[0].text ?? "")
            }
        }

        alertController.addAction(okButton)
        alertController.addAction(cancelAction(nil))
        present(alert: alertController)
    }

    class func showAddPointsAlert(onOK okCallback: @escaping (_ points: Int) -> ()) {
        let alertController = UIAlertController(title: "Add points", message: nil, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { (textField) in
            textField.keyboardType = .numberPad
        })
        alertController.addAction(okAction({ okCallback(Int(alertController.textFields?[0].text ?? "") ?? 0)}))
        present(alert:alertController)
    }

    class func showExportActivity(path: URL) {
        let activityController = UIActivityViewController(activityItems: [path], applicationActivities: nil)
        present(viewController: activityController)
    }

    //MARK: Private methods
    fileprivate class func present(alert: UIAlertController) {
        DispatchQueue.main.async {
            UIApplication.findPresentedViewController()?.present(alert, animated: true)
        }
    }

    fileprivate class func present(viewController: UIViewController) {
        DispatchQueue.main.async {
            UIApplication.findPresentedViewController()?.present(viewController, animated: true)
        }
    }

    fileprivate class func showAlert(_ title: String?, message: String, actions: [UIAlertAction]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for action in actions {
            alertController.addAction(action)
        }
        present(alert: alertController)
    }

    //MARK: Alert Actions
    fileprivate class func okAction(_ callback: AlertCallback?) -> UIAlertAction {
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            callback?()
        }
        return action
    }

    fileprivate class func cancelAction(_ callback: AlertCallback?) -> UIAlertAction {
        let action = UIAlertAction(title: "Cancel", style: .destructive) { _ in
            callback?()
        }
        return action
    }
}

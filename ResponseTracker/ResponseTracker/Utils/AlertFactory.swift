import Foundation
import UIKit

typealias AlertCallback = ()-> ()

class AlertFactory {
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

    class func showAddEmergencyTypeAlert(onOK okCallback: @escaping (_ emergencyType: String) -> ()) {
        let alertController = UIAlertController(title: "Add emergency type", message: nil, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: nil)
        alertController.addAction(okAction({ okCallback(alertController.textFields?[0].text ?? "")}))

        presentAlert(alertController)
    }

    //MARK: Private methods
    fileprivate class func presentAlert(_ alert: UIAlertController) {
        DispatchQueue.main.async {
            UIApplication.findPresentedViewController()?.present(alert, animated: true)
        }
    }

    fileprivate class func showAlert(_ title: String?, message: String, actions: [UIAlertAction]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for action in actions {
            alertController.addAction(action)
        }
        presentAlert(alertController)
    }

    //MARK: Alert Actions
    fileprivate class func okAction(_ callback: AlertCallback?) -> UIAlertAction {
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            callback?()
        }
        return action
    }

    fileprivate class func cancelAction(_ callback: AlertCallback?) -> UIAlertAction {
        let action = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            callback?()
        }
        return action
    }
}

import Foundation
import UIKit

extension UIApplication {

    class var mainWindow: UIWindow? {
        let appDelegate = shared.delegate as? AppDelegate
        return appDelegate?.window
    }

    class func findPresentedViewController(_ base: UIViewController? = mainWindow?.rootViewController) -> UIViewController? {
        if let navigationController = base as? UINavigationController,
            let visibleViewController = navigationController.visibleViewController {
            return findPresentedViewController(visibleViewController)
        }
        if let presentedController = base?.presentedViewController {
            return findPresentedViewController(presentedController)
        }
        // add additional logic if different type of controller is present (e.g Drawer)
        return base
    }

    class func rootController() -> UIViewController? {
        if let navigationController = mainWindow?.rootViewController as? UINavigationController {
            return navigationController.viewControllers.first
        }
        return mainWindow?.rootViewController
    }
}

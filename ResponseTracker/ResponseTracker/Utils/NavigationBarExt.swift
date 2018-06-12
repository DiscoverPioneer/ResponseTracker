import Foundation
import UIKit

extension UINavigationBar {
    func setGradientBackground(colors: [UIColor]) {

        var updatedFrame = bounds
        updatedFrame.size.height += self.frame.origin.y
        let gradientLayer = CAGradientLayer(frame: updatedFrame, colors: colors)

        setBackgroundImage(gradientLayer.createGradientImage(), for: UIBarMetrics.default)
    }
}

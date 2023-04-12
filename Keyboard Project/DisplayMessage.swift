//
//  DisplayMessage.swift
//  Keyboard Project
//
//  Created by Yu Xuan Yio on 10/4/2023.
//

import Foundation
import UIKit

extension UIViewController {
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}

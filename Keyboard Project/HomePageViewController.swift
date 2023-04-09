//
//  HomePageViewController.swift
//  Keyboard Project
//
//  Created by Yu Xuan Yio on 26/12/2022.
//

import UIKit
import Speech

class HomePageViewController: UIViewController {
    
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()

    override func viewDidLoad() {
        super.viewDidLoad()
        requestPermissionForSpeechRec()
        requestMicrophonePermission()
        // Do any additional setup after loading the view.
    }
    
    func requestPermissionForSpeechRec() {
        SFSpeechRecognizer.requestAuthorization {
            (authState) in
            OperationQueue.main.addOperation {
                if authState == .authorized {
                    print("ACCEPTED")
                } else if authState == .denied {
                    self.displayMessage(title: "User denied permission", message: "Please enable microphone permissions in the settings")
                } else if authState == .notDetermined {
                    self.displayMessage(title: "Error", message: "Speech recognition unavailable on this device")
                } else if authState == .restricted {
                    self.displayMessage(title: "Error", message: "This device is restricted from using speech recognition")
                }
            }
        }
    }
    
    func requestMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    print("Microphone access granted")
                    // Handle the granted case and perform necessary actions, e.g. start recording
                } else {
                    print("Microphone access denied")
                    // Handle the denied case, e.g. show an alert to inform the user
                }
            }
        }
    }

    
    
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

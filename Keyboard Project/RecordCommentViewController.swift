//
//  RecordCommentViewController.swift
//  Keyboard Project
//
//  Created by Yu Xuan Yio on 23/2/2023.
//

import UIKit
import Speech

protocol RecordCommentViewControllerDelegate: AnyObject {
    func didGetTargetData(data: String)
}

class RecordCommentViewController: UIViewController, SFSpeechRecognizerDelegate {

    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var task: SFSpeechRecognitionTask!
    var tempQuestionComments = ""
    var finalQuestionComments = ""
    var commentTimer: Timer?
    weak var commentDelegate: RecordCommentViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction))
        recordButton.addGestureRecognizer(longPressGesture)
        commentTextView.isEditable = false
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var recordButton: UIButton!
    
    @IBAction func crossButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @objc func longPressAction(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            self.recordComment()
            recordButton.imageView?.alpha = 0.5
            commentTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) {
                timer in
                gesture.state = .ended
            }
        }
        if gesture.state == .ended {
            print("Ended")
            cancelSpeechRecognition()
            recordButton.isEnabled = false
            if commentTimer?.isValid ?? true {
                commentTimer?.invalidate()
            }
            recordButton.imageView?.alpha = 1.0
            sendDataBack()
        }
    }
    
    func sendDataBack() {
        commentDelegate?.didGetTargetData(data: finalQuestionComments)
    }
    
    func recordComment() {
        startSpeechRecognition()
    }
    
    func startSpeechRecognition() {
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {
            (buffer, _) in
            self.request.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            displayMessage(title: "Error", message: "")
        }
        guard let myRecognition = SFSpeechRecognizer() else {
            self.displayMessage(title: "Error", message: "Speech recognition is not available on your device")
            return
        }
        if !myRecognition.isAvailable {
            self.displayMessage(title: "Error", message: "Recognition is not available right now")
        }
        task = speechRecognizer?.recognitionTask(with: request, resultHandler: {
            (response, error) in
            guard let response = response else {
                if error != nil {
                    print(error.debugDescription)
                } else {
                    print("Unable to provide a response")
                }
                return
            }
            let message = response.bestTranscription.formattedString
            self.tempQuestionComments = message
            self.commentTextView.text = "Your recorded comment: " + message
        })
    }
    
    func cancelSpeechRecognition() {
        task.finish()
        task.cancel()
        task = nil
        request.endAudio()
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        finalQuestionComments = tempQuestionComments
    }
    
    func requestPermissionForMic() {
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

//
//  ViewController.swift
//  Keyboard Project
//
//  Created by Yu Xuan Yio on 21/12/22.
//

import UIKit
import Vision

class QnAViewController: UIViewController {

    
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var canvasView: CanvasView!
    var requests = [VNRequest]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupVision()
    }
    
    func setupVision() {
        // load MNIST model for the use with the Vision framework
        let config = MLModelConfiguration()
        guard let coreMLModel = try? MNISTClassifier(configuration: config),
                let visionModel = try? VNCoreMLModel(for: coreMLModel.model) else {fatalError("Could not load Vision ML Model")}
        // create a classification request and tell it to call handleClassification once its done
        let classificationRequest = VNCoreMLRequest(model: visionModel, completionHandler: self.handleClassification)
        self.requests = [classificationRequest] // assigns the classificationRequest to the global requests array
    }
    
    func handleClassification (request:VNRequest, error:Error?) {
        guard let observations = request.results else {print("no results"); return}
        
        // process the ovservations
        let classifications = observations
            .compactMap({$0 as? VNClassificationObservation}) // cast all elements to VNClassificationObservation objects
            .filter({$0.confidence > 0.8}) // only choose observations with a confidence of more than 80%
            .map({$0.identifier}) // only choose the identifier string to be placed into the classifications array
        
        DispatchQueue.main.async {
            self.answerLabel.text = classifications.first // update the UI with the classification
        }
        
    }
    
    @IBAction func clearCanvas(_ sender: Any) {
        canvasView.clearCanvas()
    }
    
    @IBAction func readDigit(_ sender: Any) {
        let image = UIImage(view: canvasView) // get UIImage from CanvasView
        let scaledImage = scaleImage(image: image, toSize: CGSize(width: 28, height: 28)) // scale the image to the required size of 28x28 for better recognition results
        let imageRequestHandler = VNImageRequestHandler(cgImage: scaledImage.cgImage!, options: [:]) // create a handler that should perform the vision request
                
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
    
    // scales any UIImage to a desired target size
    func scaleImage (image:UIImage, toSize size:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}


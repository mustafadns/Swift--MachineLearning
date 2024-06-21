//
//  ViewController.swift
//  MachineLearning
//
//  Created by Mustafa DANIŞAN on 5.06.2024.
//



// Proje içerisindeki MobileNetV2 dosyasını machine learning yaptırmak için apple developer sitesinden indirip projeye dahil ettim
// Proje sadece fotoğraflar için değil çeşit çeşit şeyler için de yapılabilir web sitesinde mevcut

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    
    // UIImage şeklindeki görseli CIImage'ye çevirmemiz gerekiyor machineLearning'in tanımlaması için
    var choosenImage = CIImage()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    // Button'a tıklandığında kullanıcının galerisinden fotoğraf seçtirebilmek için yazılmış fonksiyon
    @IBAction func changeClicked(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    // Seçilen fotoğraf ile ne yapılacağını belirlemek için yazılmış fonksiyon
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        if let ciImage = CIImage(image: imageView.image!) {
            choosenImage = ciImage
        }
        recognizeImage(image: choosenImage)
    }
    
    // Fotoğrafı Machine Learninge tanımlattıktan sonra fotoğrafın tanımlamasının yapılması için yazılmış fonksiyon
    func recognizeImage(image: CIImage) {
        
        // Bekletme durumunda label'de yazacak text
        resultLabel.text = "Finding ..."
        
        // Yüklediğimiz dosyadaki verinin tanımlanması için yazılmış fonksiyon
        if let model = try? VNCoreMLModel(for: MobileNetV2().model) {
            let request = VNCoreMLRequest(model: model) { vnrequest, error in
                if let results = vnrequest.results as? [VNClassificationObservation] {
                    if results.count > 0 {
                        let topResult = results.first
                        
                        DispatchQueue.main.async {
                            let confidenceLevel = (topResult?.confidence ?? 0) * 100
                            let rounded = Int(confidenceLevel * 100) / 100
                            
                            self.resultLabel.text = "\(rounded) % it's \(topResult!.identifier)"
                        }
                    }
                }
            }
            let handler = VNImageRequestHandler(ciImage: image)
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    try handler.perform([request])
                }catch {
                    print("error")
                }
            }
        }
    }
    
}


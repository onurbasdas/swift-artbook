//
//  DetailsVC.swift
//  ArtBookProject
//
//  Created by Onur Başdaş on 25.01.2021.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    
    var chosenPainting = ""
    var chosenPaintingId : UUID?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenPainting != ""{
            //Core Data
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let idString = chosenPaintingId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0{
                    for result in results as! [NSManagedObject]{
                        if let name = result.value(forKey: "name") as? String{
                            nameText.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String{
                            artistText.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int{
                            yearText.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
            }catch{
                print("error")
            }
            
            
            fetchRequest.returnsObjectsAsFaults = false
            
            
        }else{
            nameText.text = ""
            artistText.text = ""
            yearText.text = ""
        }
        
        
        
        //Recognizers
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
        
        
    }
    
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary //kütüphaneden fotoğraf almak için kullanılır.
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage //Kesin garanti yok o yüzden soru işareti belki kapatabilir galeriden seçmeden
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPaintig = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        //Attributes
        
        newPaintig.setValue(nameText.text!, forKey: "name")
        newPaintig.setValue(artistText.text!, forKey: "artist")
        
        if let year = Int(yearText.text!){
            newPaintig.setValue(year, forKey: "year")
        }
        newPaintig.setValue(UUID(), forKey: "id") //Burada swift kendi id vericek ondan böyle kullanabiliriz.
        
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        
        newPaintig.setValue(data, forKey: "image")
        
        do{
            try context.save()
            print("success")
        }catch{
            print("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
        
    }
    
}

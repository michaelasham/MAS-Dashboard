//
//  MaterialVC.swift
//  MAS Dashboard
//
//  Created by Michael Asham on 25/10/2023.
//

import UIKit
import Firebase
import PhotosUI
import AVKit

class MaterialVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {


    @IBOutlet weak var addVideoBtn: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var available: UISwitch!
    @IBOutlet weak var descField: UITextView!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var pickerCurtain: UIView!
    
    
    var material = DoablesService.instance.selectedMaterial
    let imagePicker = UIImagePickerController()
    let storage = Storage.storage()
    let storageRef = Storage.storage().reference()

    let types = ["نيران", "صيحات", "بروتوكول", "شفرات", "صلوات", "خيام" ,"ربطات"]

    var images = [UIImage]()
    var IsEditing = false
    var videoURL = URL(string: "")
    
    var selectedType = "نيران"

    override func viewDidLoad() {
        super.viewDidLoad()
        addVideoBtn.layer.cornerRadius = 25
        materialMediaCount = 0
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = false
        collectionView.delegate = self
        collectionView.dataSource = self
        pickerView.delegate = self
        pickerView.dataSource = self
        
        let endEditingTap = UITapGestureRecognizer(target: self, action: #selector(handleEndEditingTap))
        view.addGestureRecognizer(endEditingTap)
        
        if let id = material.id {
            //old
            spinner.stopAnimating()
            saveBtn.isHidden = true
            descField.isHidden = true
            titleField.isHidden = true
            descLbl.text = material.desc
            titleLbl.text = material.name
            available.isOn = material.available
            pickerCurtain.isHidden = false
            available.isEnabled = false
            choosePickerViewItem()
            pullMedia()
        } else {
            //new
            editBtn.isHidden = true
            titleLbl.isHidden = true
            descLbl.isHidden = true
            pickerCurtain.isHidden = true
            available.isEnabled = true
            spinner.isHidden = true
        }
        NotificationCenter.default.addObserver(self, selector: #selector(addImage), name: NOTIF_ADD_IMAGE, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeMedia), name: NOTIF_REMOVE_MEDIA, object: nil)
    }
    
    @objc func handleEndEditingTap() {
        UIView.animate(withDuration: 0.2) {
            self.view.superview!.endEditing(true)
            self.view.superview!.frame.origin.y = 0
        }
    }
    
    @objc func addImage() {
        present(imagePicker, animated: true)
    }
    
    @objc func removeMedia() {
        pullMedia()
    }
    
    func pullMedia() {
        spinner.startAnimating()
        images.removeAll()
        let id = material.id!
        let jpegmetadata = StorageMetadata()
        jpegmetadata.contentType = "image/jpeg"
        let imageRef1 = storageRef.child("materials/\(id)0.jpg")
        imageRef1.getData(maxSize: 1 * 1024 * 1024) { result, error in
            if let error = error {
                self.collectionView.reloadData()
            } else {
//                image 1 available, check for image 2
                self.images.append(UIImage(data: result ?? Data())!)
                let imageRef2 = self.storageRef.child("materials/\(id)1.jpg")
                imageRef2.getData(maxSize: 1 * 1024 * 1024) { result, error in
                    if let error = error {
                        self.collectionView.reloadData()
                    } else {
//                        image 2 available, check for image 3
                        self.images.append(UIImage(data: result ?? Data())!)
                        let imageRef3 = self.storageRef.child("materials/\(id)2.jpg")
                        imageRef3.getData(maxSize: 1 * 1024 * 1024) { result, error in
                            if let error = error {
                                self.collectionView.reloadData()
                            } else {
                                self.images.append(UIImage(data: result ?? Data())!)
                                self.collectionView.reloadData()
                            }
                        }
                    }
                }
            }
        }
        //video
        spinner.startAnimating()
        let videoRef = storageRef.child("materials/\(id).mp4")
        videoRef.getData(maxSize: 180 * 1024 * 1024) { data, error in
            if error != nil {
                //no video
                print(error)
                if !self.IsEditing {
                    self.addVideoBtn.isHidden = true
                    self.spinner.stopAnimating()
                } else {
                    self.addVideoBtn.isHidden = false
                    self.addVideoBtn.setTitle("+", for: .normal)
                    self.spinner.stopAnimating()
                }
            } else {
                //video available
                videoRef.downloadURL { videoURL, error in
                    if error == nil {
                        self.videoURL = videoURL
                        self.addVideoBtn.isHidden = false
                        self.addVideoBtn.setTitle("▶️", for: .normal)
                        self.spinner.stopAnimating()
                    }
                }
            }
        }
    }
    
    @IBAction func onAddVideoClick(_ sender: Any) {
        if addVideoBtn.title(for: .normal) == "▶️" {
            spinner.startAnimating()
            let player = AVPlayer(url: self.videoURL!)
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = self.view.bounds
            self.view.layer.addSublayer(playerLayer)
            player.play()
            spinner.stopAnimating()
        } else {
            self.addVideoBtn.isEnabled = false
            available.isEnabled = false
            saveBtn.isHidden = true
            if videoURL?.pathComponents.isEmpty ?? true {
                pickAVideo()
            } else {
                //delete current video
                self.spinner.startAnimating()
                let videoRef = storageRef.child("materials/\(material.id!).mp4")
                videoRef.delete { error in
                    self.spinner.stopAnimating()
                    self.addVideoBtn.setTitle("+", for: .normal)
                    self.videoURL = URL(string: "")
                    self.saveBtn.isHidden = false
                    self.addVideoBtn.isEnabled = true
                    self.available.isEnabled = true
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaCell", for: indexPath) as? MediaCell {
            if indexPath.row < self.images.count {
                cell.setupCell(index: indexPath.row, material: self.material, image: self.images[indexPath.row], isEditing: IsEditing )
            } else {
                cell.setupCell(index: indexPath.row, material: self.material, image: UIImage(), isEditing: IsEditing)
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if images.count < 3 {
            return images.count + 1
        } else {
            return 3
        }
        
    }
    

    @IBAction func onEditClick(_ sender: Any) {
        editBtn.isHidden = true
        saveBtn.isHidden = false
        titleLbl.isHidden = true
        descLbl.isHidden = true
        pickerCurtain.isHidden = true
        available.isEnabled = true
        descField.isHidden = false
        titleField.isHidden = false
        descField.text = material.desc
        titleField.text = material.name
        IsEditing = true
        collectionView.reloadData()

        self.addVideoBtn.isHidden = false
        if videoURL?.pathComponents.isEmpty ?? true {
            self.addVideoBtn.setTitle("+", for: .normal)
        } else {
            self.addVideoBtn.setTitle("🗑️", for: .normal)
        }
    }
    
    @IBAction func onSaveClick(_ sender: Any) {
        let newMaterial = Material(id: "", name: titleField.text!, desc: descField.text!, type: selectedType, available: available.isOn)
        spinner.startAnimating()
        if let id = material.id {
            //old
            DoablesService.instance.editMaterialDetails(material: newMaterial) { Success in
                if Success {
                    self.spinner.stopAnimating()
                    self.dismiss(animated: true)
                }
            }
        } else {
            //new
            DoablesService.instance.addMaterial(material: newMaterial) { Success in
                if Success {
                    self.spinner.stopAnimating()
                    self.dismiss(animated: true)
                }
            }
        }

    }
    func pickAVideo() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .videos
        let videoPicker = PHPickerViewController(configuration: configuration)
        videoPicker.delegate = self
        present(videoPicker,animated: true)
    }
}

extension MaterialVC: PHPickerViewControllerDelegate {
    
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        spinner.startAnimating()
        guard let provider = results.first?.itemProvider else { return }
        if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            provider.loadFileRepresentation(for: UTType.movie) { result, flag,error   in
                guard let fileURL = result, error == nil else { print("failed"); return }
                do { Task { @MainActor in self.uploadVideo(URL: fileURL) }}
                print(error)
            }
        }
    }
    
    func uploadVideo(URL: URL) {
        print("uploadVideo")
        guard let videoData = try? Data(contentsOf: URL) else {
            spinner.stopAnimating()
            print("fail")
            return }
        let videoRef = self.storageRef.child("materials/\(self.material.id!).mp4")
        let videoMetadata = StorageMetadata()
        videoMetadata.contentType = "video/mp4"
        print("uploadstarted")

        let uploadTask = videoRef.putData(videoData, metadata: videoMetadata) { m, error in
            if error == nil {
                videoRef.downloadURL { videoURL, error in
                    if error == nil {
                        self.videoURL = videoURL
                        self.addVideoBtn.setTitle("▶️", for: .normal)
                        self.addVideoBtn.isEnabled = true
                        self.spinner.stopAnimating()
                    }
                }
            }
        }
        uploadTask.observe(.progress) { snapshot in
            
            if let progress = snapshot.progress {
                if progress.totalUnitCount > 0 {
                    let percentage = Double(progress.completedUnitCount) / Double(progress.totalUnitCount) * 100.0
                    let formattedPercentage = String(format: "%.1f", percentage)
                    print("\(progress.completedUnitCount) out of \(progress.totalUnitCount) - \(formattedPercentage)%")
                    self.addVideoBtn.setTitle("\(formattedPercentage)%", for: .normal)
                } else {
                    print("Total unit count is zero.")
                }
            } else {
                print("Snapshot or progress is nil.")
            }

        }
    }
    
    
}


extension MaterialVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return types.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return types[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedType = types[row]
    }
    func choosePickerViewItem() {
        var index = 0
        switch material.type {
        case "نيران":
            index = 0
        case "صيحات":
            index = 1
        case "بروتوكول":
            index = 2
        case "شفرات":
            index = 3
        case "صلوات":
            index = 4
        case "خيام":
            index = 5
        case "ربطات":
            index = 6
        default:
            index = 0
        }
        pickerView.selectRow(index, inComponent: 0, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.spinner.startAnimating()
            self.dismiss(animated: true)
            DoablesService.instance.uploadMaterialImage(image: image) { Success in
                if Success {
                    self.pullMedia()
                    self.saveBtn.isHidden = false
                    self.addVideoBtn.isEnabled = true
                    self.available.isEnabled = true
                }
            }
            }
      }
}

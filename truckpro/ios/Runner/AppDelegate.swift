import UIKit
import Flutter
import shared_preferences_foundation 

@main
@objc class AppDelegate: FlutterAppDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  var result: FlutterResult?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    //Flutter view controller
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    
    //custom MethodChannel for the image picker - name - bundle identifier
    let imagePickerChannel = FlutterMethodChannel(name: "com.example.truckpro/image_picker", binaryMessenger: controller.binaryMessenger)
    
    //MethodCallHandler to handle image picker calls
    imagePickerChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "pickImage" {
        self?.result = result
        
        //choose source camera or library
        let arguments = call.arguments as? [String: Any]
        let sourceType = arguments?["sourceType"] as? String ?? "camera" // def to camera
        
        self?.showImagePicker(controller: controller, sourceType: sourceType)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    
    //register all plugins
    GeneratedPluginRegistrant.register(with: self)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  
  private func showImagePicker(controller: UIViewController, sourceType: String) {
    let imagePickerController = UIImagePickerController()
    imagePickerController.delegate = self
    imagePickerController.allowsEditing = false
    imagePickerController.mediaTypes = ["public.image"]
    imagePickerController.modalPresentationStyle = .fullScreen
    
    //set the source type based on the argument passed
    if sourceType == "camera" {
        imagePickerController.sourceType = .camera
    } else {
        imagePickerController.sourceType = .photoLibrary
    }

     //choose native image source dialog
    let actionSheet = UIAlertController(title: "Select Image Source", message: nil, preferredStyle: .actionSheet)
    
    //option to pick from the photo library
    actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
        imagePickerController.sourceType = .photoLibrary  // Set source type to photo library
        controller.present(imagePickerController, animated: true, completion: nil)
    }))
    
    //option to use the camera
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            imagePickerController.sourceType = .camera  
            controller.present(imagePickerController, animated: true, completion: nil)
        }))
    }
  
    // add cancel action
    actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
  
    // present action sheet to allow user to choose between camera and photo library
    controller.present(actionSheet, animated: true, completion: nil)
}


  
  // UIImagePickerControllerDelegate Method
  public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
    picker.dismiss(animated: true, completion: nil)
    
    if let imageUrl = info[.imageURL] as? URL {
      // Handle image URL - photo library selection
      result?(imageUrl.path)
    } else if let image = info[.originalImage] as? UIImage {
      // Handle UIImage - camera capture 
      if let imageData = image.pngData() {
        do {
          let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
          let fileURL = directoryURL.appendingPathComponent("image.png")
          try imageData.write(to: fileURL)
          result?(fileURL.path)
        } catch {
          print("Error saving image: \(error.localizedDescription)")
          result?(nil)
        }
      } else {
        result?(nil)
      }
    } else {
      result?(nil)
    }
  }
  
  public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
    result?(nil)
  }
}
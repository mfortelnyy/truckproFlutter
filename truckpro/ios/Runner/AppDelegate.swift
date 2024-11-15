import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  var result: FlutterResult?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let imagePickerChannel = FlutterMethodChannel(name: "com.example.truckpro/image_picker", binaryMessenger: controller.binaryMessenger)

    imagePickerChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "pickImage" {
        self.result = result
        self.showImagePicker(controller: controller)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func showImagePicker(controller: UIViewController) {
    let imagePickerController = UIImagePickerController()
    imagePickerController.delegate = self  // Ensure `self` conforms to `UIImagePickerControllerDelegate`
    imagePickerController.sourceType = .camera
    imagePickerController.allowsEditing = false
    imagePickerController.mediaTypes = ["public.image"]
    imagePickerController.modalPresentationStyle = .fullScreen
    controller.present(imagePickerController, animated: true, completion: nil)
  }

  // UIImagePickerControllerDelegate Method
  public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true, completion: nil)
    
    // Log the entire info dictionary for debugging purposes
    print("Image Picker Info: \(info)")

    if let imageUrl = info[.imageURL] as? URL {
        // If imageURL is available (from photo library)
        result?(imageUrl.path)
    } else if let image = info[.originalImage] as? UIImage {
        // If originalImage is available (from camera or new photo)
        
        // Convert UIImage to PNG data
        if let imageData = image.pngData() {
            // Save the image to the app's documents directory
            let fileManager = FileManager.default
            do {
                let directoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileURL = directoryURL.appendingPathComponent("image.png")
                
                // Write image data to file
                try imageData.write(to: fileURL)
                
                // Pass the file path back to Flutter
                result?(fileURL.path)
            } catch {
                print("Error saving image: \(error.localizedDescription)")
                result?(nil)
            }
        }
    } else {
        // If no image is available
        result?(nil)
    }
}

}

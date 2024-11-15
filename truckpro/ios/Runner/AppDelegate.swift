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
    let imagePickerChannel = FlutterMethodChannel(name: "com.yourapp/image_picker", binaryMessenger: controller.binaryMessenger)

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
    imagePickerController.delegate = self
    imagePickerController.sourceType = .camera
    imagePickerController.allowsEditing = false
    imagePickerController.mediaTypes = ["public.image"]
    imagePickerController.modalPresentationStyle = .fullScreen
    
    // Present the camera with access to the photo library
    controller.present(imagePickerController, animated: true, completion: nil)
  }

  public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true, completion: nil)
    if let imageUrl = info[.imageURL] as? URL {
      result?(imageUrl.path)
    } else {
      result?(nil)
    }
  }

  public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
    result?(nil)
  }
}

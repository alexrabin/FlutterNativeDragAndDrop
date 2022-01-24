import Flutter
import UIKit
import MobileCoreServices
import Foundation

class MediaTypes {
    static let IMAGE_IDS : [String] = [kUTTypeImage as String,kUTTypeJPEG as String, kUTTypePNG as String]
    static let VIDEO_IDS : [String] = [kUTTypeMovie as String, kUTTypeMPEG as String, kUTTypeMPEG4 as String, kUTTypeVideo as String, kUTTypeQuickTimeMovie as String]
}

public class SwiftNativeDragNDropPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "native_drag_n_drop", binaryMessenger: registrar.messenger())
    let instance = SwiftNativeDragNDropPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    let viewfactory = DropPlatformViewFactory(messenger: registrar.messenger())
    registrar.register(viewfactory, withId: "DropPlatformView")
  }
}

public class DropPlatformViewFactory: NSObject, FlutterPlatformViewFactory{
    
    private var messenger: FlutterBinaryMessenger

        init(messenger: FlutterBinaryMessenger) {
            self.messenger = messenger
            super.init()
        }

    public func create(
            withFrame frame: CGRect,
            viewIdentifier viewId: Int64,
            arguments args: Any?
        ) -> FlutterPlatformView {
            return DropPlatformView(
                frame: frame,
                viewIdentifier: viewId,
                arguments: args,
                binaryMessenger: messenger)
        }
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
       return FlutterStandardMessageCodec.sharedInstance()
     }
}
public class DropPlatformView: NSObject, FlutterPlatformView, UIDropInteractionDelegate {
    private var _view: UIView
    let viewId: Int64
    let messenger: FlutterBinaryMessenger
    let channel: FlutterMethodChannel
    var _allowedDropDataTypes: [String]?
    var _allowedDropFileExtensions: [String]?
    var _allowedTypeIdentifiers : [String] = []
    private var _allowedTotal : Int = 0
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        self.messenger = messenger
        self.viewId = viewId
        _view = UIView()
        channel = FlutterMethodChannel(name: "DropView/\(viewId)",
                                                        binaryMessenger: messenger)

        super.init()
        // iOS views can be created here
        _view.backgroundColor = UIColor.clear
        if let flutterArgs = args as? [String: Any] {
            updateAllowedTotalExtsData(flutterArgs: flutterArgs)
          if let backgroundColor = flutterArgs["backgroundColor"] as? [Int]{
            if backgroundColor.count > 0{
              let colorValues = backgroundColor.map {
                    CGFloat($0)
                }
              let color = UIColor(red: colorValues[0]/255, green: colorValues[1]/255, blue: colorValues[2]/255, alpha: colorValues[3]/255)
              _view.backgroundColor = color
            }
          }
          if let borderColor = flutterArgs["borderColor"] as? [Int], let borderWidth = flutterArgs["borderWidth"] as? Int{
              if borderColor.count > 0{
                let colorValues = borderColor.map {
                    CGFloat($0)
                }
              let color = UIColor(red: colorValues[0]/255, green: colorValues[1]/255, blue: colorValues[2]/255, alpha: colorValues[3]/255)
              _view.layer.borderColor = color.cgColor
              _view.layer.borderWidth = CGFloat(borderWidth)
            }
          }
          
        }

        channel.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if call.method == "updateParams"{
                if let flutterArgs = call.arguments as? [String: Any]{
                    self?.updateAllowedTotalExtsData(flutterArgs: flutterArgs)

                }
            }
        })
        let dropInteraction = UIDropInteraction(delegate: self)
        _view.addInteraction(dropInteraction)

    }
    
    public func view() -> UIView {
        return _view
    }

    public func sendDropData(_ data: Any){
        channel.invokeMethod("receivedDropData", arguments: data)
    }
    
    public func sendLoadingNotification(){
        channel.invokeMethod("loadingData", arguments: "Loading your data")
    }
    
    private func updateAllowedTotalExtsData(flutterArgs : [String: Any]) {
        if let allowedTotal = flutterArgs["allowedTotal"] as? Int   {
            self._allowedTotal = allowedTotal
        }
        if let dropDataTypes = flutterArgs["allowedDropDataTypes"] as? [String] {
            self._allowedDropDataTypes = dropDataTypes
            self._allowedTypeIdentifiers = []
            for dropType in _allowedDropDataTypes! {
                if dropType == "text" {
                    self._allowedTypeIdentifiers.append(kUTTypePlainText as String)
                }
                else if dropType == "url" {
                    self._allowedTypeIdentifiers.append(kUTTypeURL as String)
                }
                else if dropType == "image" {
                    self._allowedTypeIdentifiers.append(contentsOf:MediaTypes.IMAGE_IDS)
                }
                else if dropType == "video" {
                    self._allowedTypeIdentifiers.append(contentsOf: MediaTypes.VIDEO_IDS)
                }
                else if dropType == "audio" {
                    self._allowedTypeIdentifiers.append(kUTTypeAudio as String)
                }
                else if dropType == "pdf" {
                    self._allowedTypeIdentifiers.append(kUTTypePDF as String)
                }
                else if dropType == "file" {
                    self._allowedTypeIdentifiers.append(kUTTypeData as String)
                }
            }
        }
        if let dropFileExtensions = flutterArgs["allowedDropFileExtensions"] as? [String] {
          self._allowedDropFileExtensions = dropFileExtensions
        }
    }
    
    
    
    private func isDirectory(_ item: UIDragItem) -> Bool {
        return item.itemProvider.hasItemConformingToTypeIdentifier(kUTTypeDirectory as String)
    }
    
    private func isFileOrDirectory(_ item: UIDragItem) -> Bool {
        return item.itemProvider.hasItemConformingToTypeIdentifier(kUTTypeItem as String)
    }
    
    private func isDocument(_ item: UIDragItem) -> Bool {
        // Can be document, pasteboard data, or  document packages
        // https://web.archive.org/web/20190621082935/https://developer.apple.com/documentation/mobilecoreservices/uttype/uti_abstract_types
        return item.itemProvider.hasItemConformingToTypeIdentifier(kUTTypeContent as String)
    }
    
    private func isFile(_ item: UIDragItem) -> Bool {
        return (!isDirectory(item) && isFileOrDirectory(item)) || isDocument(item)
    }
    
    private func getExtensionCodeFromUTI(_ typeIdentifier: String) -> String? {
        let cfExtensionName = UTTypeCopyPreferredTagWithClass(typeIdentifier as CFString, kUTTagClassFilenameExtension)
        let extensionName = cfExtensionName?.takeRetainedValue() as String?
        return extensionName
    }
    
    private func getSessionExtensionCodes(_ session: UIDropSession) -> [String] {
        // Use the Uniform Type Identifiers to get the file extensions since
        // `session.items.first?.itemProvider.suggestedName` does not include the file extension
        var UTIList: [String] = []
        for item: UIDragItem in session.items {
            let itemProvider: NSItemProvider = item.itemProvider
            let itemTypeIdentifiers: [String] = itemProvider.registeredTypeIdentifiers
            UTIList.append(contentsOf: itemTypeIdentifiers)
        }

        // Convert Uniform Type Identifier to Extension, code found here: https://stackoverflow.com/questions/49118095/ios-11-extracting-filename-when-doing-drag-and-drop-pdf-from-dropbox
        var droppedFileExtensionList: [String] = []
        for typeIdentifier: String in UTIList {
            let extensionName = getExtensionCodeFromUTI(typeIdentifier)
            if extensionName == nil {
                continue
            }

            droppedFileExtensionList.append(extensionName!.lowercased())
        }
        
//        // Converting extensions to UTI to check if the dropped files matches does not work because not all filetypes have a UTI
//        // Convert the file extension to Uniform Type Identifier to
//        var allowedExtensionTypeIdentifierList: [String] = []
//        for fileExtension: String in allowedDropFileExtensions! {
//            let cfTypeIdentifier = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension.lowercased() as CFString, nil)
//            let typeIdentifier = cfTypeIdentifier?.takeRetainedValue() as String?
//
//            if typeIdentifier == nil {
//                continue
//            }
//
//            allowedExtensionTypeIdentifierList.append(typeIdentifier!)
//        }
//        let hasItemsWithAllowedExtensions: Bool = Set(allowedExtensionTypeIdentifierList).intersection(UTIList).count > 0
//        let hasItemsConformingToOtherTypeIdentifiers: Bool = session.hasItemsConforming(toTypeIdentifiers: allowedTypeIdentifiers.filter({$0 != kUTTypeData as String}))
        
        return droppedFileExtensionList
    }
    
    private func hasAllowedExtensionCode(_ session: UIDropSession) -> Bool {
        let extensionCodes = getSessionExtensionCodes(session)
        return Set(extensionCodes).intersection(Set(self._allowedDropFileExtensions!)).count > 0
    }
    
    private func hasFile(_ session: UIDropSession) -> Bool {
        for item: UIDragItem in session.items {
            if isFile(item) {
                return true
            }
        }
        
        return false
    }
    
    private func shouldAllowAllFiles() -> Bool {
        return self._allowedTypeIdentifiers.contains(kUTTypeData as String)
    }
    
    private func hasItemsConformingToAllowedTypeIdentifiers(_ session: UIDropSession) -> Bool {
        return session.hasItemsConforming(toTypeIdentifiers: self._allowedTypeIdentifiers) || (hasFile(session) && shouldAllowAllFiles() )
    }
    
    public func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        
        // If items count is greater than allowed count then can handle returns false
        if self._allowedTotal != 0 && session.items.count > self._allowedTotal {
            return false
        }
        
        // If no data types are specified, allow all types
        if self._allowedDropFileExtensions == nil {
            return session.hasItemsConforming(toTypeIdentifiers: self._allowedTypeIdentifiers) || (hasFile(session) && shouldAllowAllFiles() )
        }
        
        return hasAllowedExtensionCode(session) || hasItemsConformingToAllowedTypeIdentifiers(session)
    }

    public func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
            // Propose to the system to copy the item from the source app
        return UIDropProposal(operation: .copy)
    }
    
    private func shouldAllowUrls() -> Bool {
        return self._allowedTypeIdentifiers.contains(kUTTypeURL as String)
    }
    
    private func shouldAllowPlainText() -> Bool {
        return self._allowedTypeIdentifiers.contains(kUTTypePlainText as String)
    }
    
    private func shouldAllowAudio() -> Bool {
        return self._allowedTypeIdentifiers.contains(kUTTypeAudio as String)
    }
    
    private func shouldAllowImages() -> Bool {
        for imageID in MediaTypes.IMAGE_IDS {
            if self._allowedTypeIdentifiers.contains(imageID) {
                return true
            }
        }
        
        return false
    }
    
    private func shouldAllowVideos() -> Bool {
        for videoID in MediaTypes.VIDEO_IDS {
            if self._allowedTypeIdentifiers.contains(videoID) {
                return true
            }
        }
        
        return false
    }

    private func shouldAllowPDFs() -> Bool {
        return self._allowedTypeIdentifiers.contains(kUTTypePDF as String)
    }

    
    public func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        var data : [Any] = []
        let group = DispatchGroup()
        if (session.items.count > 0){
            sendLoadingNotification()
        }
        
        for item in session.items {
            // Return item with the correct type
            if item.itemProvider.canLoadObject(ofClass: String.self) {
                group.enter()

                _ = item.itemProvider.loadObject(ofClass: String.self) { reading, err in

                    if (err == nil && reading != nil){
                        
                        if reading!.contains("data:image"){
                            
                            if let imageData = Data(base64Encoded: reading!), let savedURL = self.saveImage(imageData: imageData) {
                                data.append(["image": savedURL])

                            }
                        }
                        else {
                            let ids = item.itemProvider.registeredTypeIdentifiers
                            var textData = ["text": reading!]
                            if ids.contains(where: { s in
                                s.contains("javascript")
                            }){
                                textData["fileType"] = "javascript"
                            }
                            else if ids.contains(where: { s in
                                s.contains("python")
                            }){
                                textData["fileType"] = "python"
                            }
                            else if ids.contains(where: { s in
                                s.contains("objective-c")
                            }){
                                textData["fileType"] = "objectivec"
                            }
                            else if ids.contains(where: { s in
                                s.contains("java")
                            }){
                                textData["fileType"] = "java"
                            }
                            else if ids.contains(where: { s in
                                s.contains("swift")
                            }){
                                textData["fileType"] = "swift"
                            }
                            data.append(textData)
                        }
                    }
                    group.leave()

                }
            }
            else if item.itemProvider.canLoadObject(ofClass: NSURL.self) {
                group.enter()

                item.itemProvider.loadObject(ofClass: NSURL.self) { reading, err in

                    if (err == nil && reading != nil){
                        data.append(["url": reading!.description])
                        
                    }
                    group.leave()

                }
            }
            else if item.itemProvider.hasItemConformingToTypeIdentifier(kUTTypeAudio as String) && shouldAllowAudio() {
                group.enter()

                item.itemProvider.loadFileRepresentation(forTypeIdentifier: kUTTypeAudio as String) { url, err in

                    if (err == nil && url != nil){
                        if let fileURL = self.saveFileURL(userURL: url!){
                            data.append(["audio": fileURL])

                        }
                    }
                    group.leave()

                }
            }
            else if hasItemsConformingToTypeIdentifiers(itemProvider: item.itemProvider, identifiers: MediaTypes.IMAGE_IDS) && shouldAllowImages() {
                group.enter()
                item.itemProvider.loadFileRepresentation(forTypeIdentifier: item.itemProvider.registeredTypeIdentifiers[0]) { url, err in

                    if (err == nil && url != nil){
                        if let imageURL = self.saveImageURL(userImageURL: url!){
                            data.append(["image": imageURL])

                        }
                    }
                    group.leave()

                }
            }
            else if hasItemsConformingToTypeIdentifiers(itemProvider: item.itemProvider, identifiers: MediaTypes.VIDEO_IDS) && shouldAllowVideos() {
                group.enter()
                item.itemProvider.loadFileRepresentation(forTypeIdentifier: item.itemProvider.registeredTypeIdentifiers[0]) { url, err in
                     if (err == nil && url != nil){
                        if let fileURL = self.saveFileURL(userURL: url!){
                            data.append(["video": fileURL])

                        }
                    }
                    group.leave()

                }
            }
            else if item.itemProvider.hasItemConformingToTypeIdentifier(kUTTypePDF as String) && shouldAllowPDFs() {
                group.enter()

                item.itemProvider.loadFileRepresentation(forTypeIdentifier: kUTTypePDF as String) { url, err in
                    if (err == nil && url != nil){
                        if let fileURL = self.saveFileURL(userURL: url!){
                            data.append(["pdf": fileURL])

                        }
                    }
                    group.leave()

                }
            }
            // No need to check if the file extension is allowed here because it was already checked in isAllowed()
            else if isFile(item) {
                group.enter()

                item.itemProvider.loadFileRepresentation(forTypeIdentifier: kUTTypeItem as String) { url, err in

                    if (err == nil && url != nil){
                        if let fileURL = self.saveFileURL(userURL: url!){
                            data.append(["file": fileURL])

                        }
                    }
                    group.leave()

                }
            }
        }
        group.notify(queue: .main) {
            self.sendDropData(data)
            
        }
    }

    func hasItemsConformingToTypeIdentifiers(itemProvider : NSItemProvider, identifiers : [String]) -> Bool{
        for id in identifiers{
            if itemProvider.hasItemConformingToTypeIdentifier(id) && self._allowedTypeIdentifiers.contains(id){
                return true
            }
        }
        return false
    }
    
    func saveImageURL(userImageURL: URL) -> String? {
        let filename : NSString = NSString(string: userImageURL.lastPathComponent)
        let fileManager = FileManager()
        
        if let image = UIImage(contentsOfFile: userImageURL.path) {
            let data = image.jpegData(compressionQuality: 1)
            let fileName = NSString(string: filename.lastPathComponent).deletingPathExtension + UUID().uuidString
            let tempFile = NSTemporaryDirectory().appending(fileName.appending(".jpeg"))
            if fileManager.fileExists(atPath: tempFile){
                guard ((try? fileManager.removeItem(atPath: tempFile)) != nil) else {
                    return nil
                }
            }
            if fileManager.createFile(atPath: tempFile, contents: data, attributes: nil){
                return tempFile
            }
        }
       
        return nil
    }
    
    func saveImage(imageData : Data) -> String? {
        let fileManager = FileManager()
        let tempFile = NSTemporaryDirectory().appending(UUID().uuidString.appending(".jpeg"))

        if fileManager.fileExists(atPath: tempFile){
            guard ((try? fileManager.removeItem(atPath: tempFile)) != nil) else {
                return nil
            }
        }
        if fileManager.createFile(atPath: tempFile, contents: imageData, attributes: nil){
            return tempFile
        }
        
        return nil
    }
    
    func saveFileURL(userURL: URL) -> String? {
        let fileManager = FileManager()

        let filename = (UUID().uuidString + userURL.lastPathComponent).replacingOccurrences(of: "%20", with: " ")
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = URL(fileURLWithPath: path)
        let filePath = url.appendingPathComponent(filename)
        if fileManager.fileExists(atPath: filePath.path){
            guard ((try? fileManager.removeItem(atPath: filePath.path)) != nil) else {
                return nil
            }
        }
        guard ((try? fileManager.copyItem(at: userURL, to: filePath)) != nil) else {

            return nil
        }

        return filePath.path.replacingOccurrences(of: "file://", with: "")
    }
    
    func clearTempFiles(){
        let tempDirectory = NSTemporaryDirectory()
        let fileManager = FileManager.default
        if let cacheFiles = try? fileManager.contentsOfDirectory(atPath: tempDirectory) {
            for file in cacheFiles{
                guard ((try? fileManager.removeItem(atPath:  tempDirectory.appending(file))) != nil) else {
                    return
                }
            }
        }
    }
}


import Dyson

@available(iOS 10.0, *)
@objc(Dyson) class Dyson : CDVPlugin {
    
    private var hasSubscribedToNotifications = false
    var completedUploadsIds : [String]!
    
    @objc(setEnvironment:)
    func setEnvironment(command: CDVInvokedUrlCommand) {
        
        self.completedUploadsIds = [String]()
        
        if !hasSubscribedToNotifications
        {
            NotificationHelper.sharedInstance.subscribeToPendingUploadsEvent(observer: self, selector: #selector(updateUploadsLeft(_:)))
            NotificationHelper.sharedInstance.subscribeToUploadCompletedEvent(observer: self, selector: #selector(uploadCompleted(_:)))
            NotificationHelper.sharedInstance.subscribeToChangeStatusEvent(observer: self, selector: #selector(changeStatus(_:)))
            
            self.hasSubscribedToNotifications = true
        }
        
//        UploadManager.sharedInstance.emptyDataBase()
        
        var pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR
        )
        
        if let environment = command.arguments[0] as? String
        {
            UploadManager.sharedInstance.environment = environment
            Logger.sharedInstance.isLoggingEnabled = environment != Environment.PROD.rawValue
            
            pluginResult = CDVPluginResult(
                status: CDVCommandStatus_OK,
                messageAs: "Environment Updated Successfully"
            )
        }else{
            pluginResult = CDVPluginResult(
                status: CDVCommandStatus_ERROR,
                messageAs: "Environment Update Failed"
            )
        }
        
        self.commandDelegate!.send(
            pluginResult,
            callbackId: command.callbackId
        )
        
    }
    
    @objc(getPendingUploads:)
    func getPendingUploads(command: CDVInvokedUrlCommand) {
        
        let pendingUploads = UploadManager.sharedInstance.getTotalPendingUploads()
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: pendingUploads)
        
        self.commandDelegate!.send(
            pluginResult,
            callbackId: command.callbackId
        )
        
    }
    
    @objc(getCompleteUploadIds:)
    func getCompleteUploadIds(command: CDVInvokedUrlCommand) {
        
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: [])
        if let uploadCompleted = self.completedUploadsIds
        {
            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: uploadCompleted)
        }
        
        self.commandDelegate!.send(
            pluginResult,
            callbackId: command.callbackId
        )
    }
    
    @objc(startTransmissionOfUploadsOnLogin:)
    func startTransmissionOfUploadsOnLogin(command: CDVInvokedUrlCommand) {
        DispatchQueue.global(qos: .background).async {
            UploadManager.sharedInstance.startUploadingEnrollmentsFromDB(andKeychain: true)
        }
    }
    
    @objc(startTransmissionOfUploads:)
    func startTransmissionOfUploads(command: CDVInvokedUrlCommand) {
        DispatchQueue.global(qos: .background).async {
            UploadManager.sharedInstance.startUploadingEnrollmentsFromDB(andKeychain: false)
        }
    }
    
    @objc(removeSuccessfulRecordsFromDevice:)
    func removeSuccessfulRecordsFromDevice(command: CDVInvokedUrlCommand) {
        DispatchQueue.global(qos: .background).async {
            UploadManager.sharedInstance.removeSuccessfulRecordsFromDevice()
        }
    }
    
    @objc(startTransmissionOfEnrollmentEntry:)
    func startTransmissionOfEnrollmentEntry(command: CDVInvokedUrlCommand) {
        
        var pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR
        )
        if let enrollmentData = command.arguments[0] as? String,
            let uniqueId = command.arguments[1] as? String,
            let enrollmentIdentifier = command.arguments[2] as? String
        {
            DispatchQueue.global(qos: .background).async {
            
                let enrollmentEntry = ACPTModel(uniqueMessageID: uniqueId, data: enrollmentData, status: "\(EnrollmentStatusType.SEND_TO_HQ_INITIATED)", enrollmentIdentifier: enrollmentIdentifier)
                
                UploadManager.sharedInstance.startTransmissionOfCompleteEnrollment(entry: enrollmentEntry)
                { (error, response) in
                    
                    if(error == nil){
                        pluginResult = CDVPluginResult(
                            status: CDVCommandStatus_OK,
                            messageAs: uniqueId
                        )
                        Logger.sharedInstance.logInfo(info: "Data Sent Successfully!")
                        Logger.sharedInstance.logInfo(info: "Data received is \(response!)")
                    }
                    else{
                        pluginResult = CDVPluginResult(
                            status: CDVCommandStatus_ERROR,
                            messageAs: uniqueId
                        )
                        Logger.sharedInstance.logError(error: "Data Send Failed! : \(error?.localizedDescription)")
                    }
                    
                    self.commandDelegate!.send(
                        pluginResult,
                        callbackId: command.callbackId
                    )
                    
                }
                
            }
            
        }else{
            pluginResult = CDVPluginResult(
                status: CDVCommandStatus_ERROR,
                messageAs: "Invalid parameters"
            )
            
            self.commandDelegate!.send(
                pluginResult,
                callbackId: command.callbackId
            )
            
        }
        
    }
    
    @objc(startTransmissionOfBlob:)
    func startTransmissionOfBlob(command: CDVInvokedUrlCommand) {
        
        var pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR
        )
        
        if let enrollmentData = command.arguments[0] as? String,
            let uniqueId = command.arguments[1] as? String,
            let blobFolder = command.arguments[2] as? String,
            let enrollmentIdentifier = command.arguments[3] as? String
        {
            DispatchQueue.global(qos: .background).async {
                let enrollmentEntry = ACPTModel(uniqueMessageID: uniqueId, data: enrollmentData, status: "\(EnrollmentStatusType.SEND_TO_BLOB_INITIATED)", enrollmentIdentifier: enrollmentIdentifier)
                
                UploadManager.sharedInstance.startTransmissionOfBlob(entry: enrollmentEntry, blobFolder: blobFolder)
                {
                    (error, response) in
                    
                    if(error == nil){
                        pluginResult = CDVPluginResult(
                            status: CDVCommandStatus_OK,
                            messageAs: uniqueId
                        )
                        Logger.sharedInstance.logInfo(info: "Blob Sent Successfully!")
                        Logger.sharedInstance.logInfo(info: "Response received is \(response!)")
                    }
                    else{
                        pluginResult = CDVPluginResult(
                            status: CDVCommandStatus_ERROR,
                            messageAs: uniqueId
                        )
                        Logger.sharedInstance.logError(error: "Blob Send Failed! : \(String(describing: error?.localizedDescription))")
                    }
                    
                    self.commandDelegate!.send(
                        pluginResult,
                        callbackId: command.callbackId
                    )
                    
                }
            }
            
        }else{
            pluginResult = CDVPluginResult(
                status: CDVCommandStatus_ERROR,
                messageAs: "Invalid parameters"
            )
            
            self.commandDelegate!.send(
                pluginResult,
                callbackId: command.callbackId
            )
            
        }
        
    }
    
    @objc private func updateUploadsLeft(_ notification : NSNotification){
        let pendingUploads = notification.userInfo?["pendingUploads"] as! Int
        let command = CDVPluginHelper.sharedInstance.getJavascriptChangeUpdateCurrentUploadedItemsCommandFor(uploadsLeft: pendingUploads)
        Logger.sharedInstance.logInfo(info: "updateUploadsLeft : \(command)")
        self.commandDelegate.evalJs(command)
    }
    
    @objc private func uploadCompleted(_ notification : NSNotification){
        let messageId = notification.userInfo?["messageId"] as! String
        Logger.sharedInstance.logInfo(info: "uploadCompleted : \(self.completedUploadsIds)")
        self.completedUploadsIds.append(messageId)
        let command = "window.uploadCompleted();"
        self.commandDelegate.evalJs(command)
    }
    
    @objc private func changeStatus(_ notification : NSNotification){
        let status = notification.userInfo?["status"] as! Int
        let command = CDVPluginHelper.sharedInstance.getJavascriptChangeStatusCommandFor(status : status)
        Logger.sharedInstance.logInfo(info: "changeStatus : \(command)")
        self.commandDelegate.evalJs(command)
    }
    
}


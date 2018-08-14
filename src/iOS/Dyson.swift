import Dyson
@objc(Dyson) class Dyson : CDVPlugin {
    
    @objc(setEnvironment:)
    func setEnvironment(command: CDVInvokedUrlCommand) {
        
        NotificationHelper.sharedInstance.subscribeToUpdateUploadLeftEvent(observer: self, selector: #selector(updateUploadsLeft))
        
        var pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR
        )
        
        if let environment = command.arguments[0] as? String
        {
            EnrollmentHelper.sharedInstance.environment = environment
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
        
        let pendingUploads = EnrollmentHelper.sharedInstance.getTotalPendingUploads()
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: pendingUploads)

        self.commandDelegate!.send(
            pluginResult,
            callbackId: command.callbackId
        )
        
    }
    
    @objc(startTransmissionOfUploadsOnLogin:)
    func startTransmissionOfUploadsOnLogin(command: CDVInvokedUrlCommand) {
        EnrollmentHelper.sharedInstance.startTransmissionOfUploadsOnLogin()
    }
    
    @objc(startTransmissionOfEnrollmentEntry:)
    func startTransmissionOfEnrollmentEntry(command: CDVInvokedUrlCommand) {
        
        var pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR
        )
        
        if let enrollmentData = command.arguments[0] as? String,
            let messageId = command.arguments[1] as? String
        {
            let enrollmentEntry = ACPTModel(uniqueMessageID: messageId, data: enrollmentData, status: "\(EnrollmentStatusType.SEND_TO_HQ_INITIATED)", environment: EnrollmentHelper.sharedInstance.environment)
            
            EnrollmentHelper.sharedInstance.startTransmissionOfCompleteEnrollment(entry: enrollmentEntry)
            { (error, response) in
                
                if(error == nil){
                    pluginResult = CDVPluginResult(
                        status: CDVCommandStatus_OK,
                        messageAs: response
                    )
                    Logger.sharedInstance.logInfo(info: "Data Sent Successfully!")
                    Logger.sharedInstance.logInfo(info: "Data received is \(response!)")
                }
                else{
                    pluginResult = CDVPluginResult(
                        status: CDVCommandStatus_ERROR,
                        messageAs: error?.localizedDescription
                    )
                    Logger.sharedInstance.logError(error: "Data Send Failed!")
                }
                
                self.commandDelegate!.send(
                    pluginResult,
                    callbackId: command.callbackId
                )
                
            }
            
        }
        
    }
    
    @objc(startTransmissionOfBlob:)
    func startTransmissionOfBlob(command: CDVInvokedUrlCommand) {
        
        var pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR
        )
        
        if let enrollmentData = command.arguments[0] as? String,
            let messageId = command.arguments[1] as? String,
            let blobFolder = command.arguments[2] as? String
        {
            let enrollmentEntry = ACPTModel(uniqueMessageID: messageId, data: enrollmentData, status: "\(EnrollmentStatusType.SEND_TO_BLOB_INITIATED)", environment: EnrollmentHelper.sharedInstance.environment)
            
            EnrollmentHelper.sharedInstance.startTransmissionOfBlob(entry: enrollmentEntry, blobFolder: blobFolder)
            { (error, response) in
                
                if(error == nil){
                    pluginResult = CDVPluginResult(
                        status: CDVCommandStatus_OK,
                        messageAs: response
                    )
                    Logger.sharedInstance.logInfo(info: "Blob Sent Successfully!")
                    Logger.sharedInstance.logInfo(info: "Response received is \(response!)")
                }
                else{
                    pluginResult = CDVPluginResult(
                        status: CDVCommandStatus_ERROR,
                        messageAs: error?.localizedDescription
                    )
                    Logger.sharedInstance.logError(error: "Blob Send Failed!")
                }
                
                self.commandDelegate!.send(
                    pluginResult,
                    callbackId: command.callbackId
                )
                
            }
            
        }
        
    }
    
    @objc private func updateUploadsLeft(){
        let pendingUploads = EnrollmentHelper.sharedInstance.getTotalPendingUploads()
        let command = CDVPluginHelper.sharedInstance.getJavascriptChangeUpdateCurrentUploadedItemsCommandFor(uploadsLeft: pendingUploads)
        self.commandDelegate.evalJs(command)
    }
    
}


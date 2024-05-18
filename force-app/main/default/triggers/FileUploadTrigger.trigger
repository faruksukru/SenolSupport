trigger FileUploadTrigger on ContentDocumentLink (after insert) {
     FileUploadTriggerHandler.fileUpload(Trigger.new);

}
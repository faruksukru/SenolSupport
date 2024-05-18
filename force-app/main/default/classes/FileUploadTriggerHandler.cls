public with sharing class FileUploadTriggerHandler {
    public static void fileUpload(List<ContentDocumentLink> allLink){
    List<ContentDocumentLink> newLinks = new List<ContentDocumentLink>();
    for (ContentDocumentLink link : allLink) {
        if (link.LinkedEntityId.getSObjectType() == Account.SObjectType) {
            List<Contact> relatedContacts = [SELECT Id FROM Contact WHERE AccountId = :link.LinkedEntityId];
            List<Opportunity> relatedOpportunities = [SELECT Id FROM Opportunity WHERE AccountId = :link.LinkedEntityId];
            
            for (Contact contact : relatedContacts) {
                ContentDocumentLink contactLink = new ContentDocumentLink(
                    ContentDocumentId = link.ContentDocumentId,
                    LinkedEntityId = contact.Id,
                    ShareType = 'I', // Define the appropriate ShareType
                    Visibility = 'AllUsers' // Define the appropriate Visibility
                );
                newLinks.add(contactLink);
            }
            
            for (Opportunity opportunity : relatedOpportunities) {
                ContentDocumentLink opportunityLink = new ContentDocumentLink(
                    ContentDocumentId = link.ContentDocumentId,
                    LinkedEntityId = opportunity.Id,
                    ShareType = 'I', // Define the appropriate ShareType
                    Visibility = 'AllUsers' // Define the appropriate Visibility
                );
                newLinks.add(opportunityLink);
            }
        }
    }
    
    if (!newLinks.isEmpty()) {
        insert newLinks;
    }

    }
}
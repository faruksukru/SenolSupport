public with sharing class AccountTriggerHandler {

public static void adressCheck (List<Account> accList) {
for(Account acc:accList){
if(acc.BillingCity == null){
acc.BillingCity.addError('BillingCity Field can not be Blank');
}
if(acc.BillingCountry == null){
acc.BillingCountry.addError('BillingCountry Field can not be Blank');
}
if(acc.BillingStreet == null){
acc.BillingStreet.addError('BillingStreet Field can not be Blank');
}
if(acc.BillingPostalCode == null){
acc.BillingPostalCode.addError('BillingPostalCode Field can not be Blank');
}
if(acc.ShippingCity == null){
acc.ShippingCity = acc.BillingCity;
}
if(acc.ShippingCountry == null){
acc.ShippingCountry= acc.BillingCountry;
}
if(acc.ShippingStreet == null){ 
acc.ShippingStreet = acc.BillingStreet;   
}
if(acc.ShippingPostalCode == null){     
acc.ShippingPostalCode = acc.BillingPostalCode;       
}
}
}

public static void annualRevenue(List<Account> accList){
for(Account acc:accList){
if(acc.annualRevenue == null){
acc.annualRevenue.addError ('Annual Revenue Field can not be Blank');
}
if(acc.annualRevenue <10000){
acc.CustomerPriority__c ='Low';
} else if(acc.annualRevenue >=10000 && acc.annualRevenue <100000){
acc.CustomerPriority__c='Medium';
} else{
acc.CustomerPriority__c='High';
}
}
}

public static void createContactOpp(List<Account> accList){
    List<Contact> conList = new List<Contact>();
    List<Opportunity> oppList = new List<Opportunity>();
    for(Account acc: accList){
        Contact con = new Contact();
        Opportunity opp = new Opportunity(); 
        con.LastName = 'Contact of '+acc.Name;
        con.AccountId = acc.Id;
        conList.add(con);
        opp.Name = 'Opportunity of '+acc.Name;
        opp.AccountId = acc.Id;
        opp.CloseDate = System.today()+30;
        opp.StageName = 'Prospecting';
        oppList.add(opp);
    }
    if(conList.size()>0){// Bu kısım for dongusu icerisine yazılmaz.
        Database.SaveResult[] results = Database.insert(conList, false); //After kullandigimiz icin Database kullandık, Contact listi database'e aktardık.
    }  
    if(oppList.size()>0){
        Database.SaveResult[] results = Database.insert(oppList, false); 
    }
}

public static void shareAccountsWithUser(List<Account> accList){
   List<User> allUsers= [SELECT id FROM User WHERE ProfileId='00eWs000000DSZZ']; 
    List<AccountShare> accShares = new List<AccountShare>();
    for(Account acc:accList){
        for(User u:allUsers){
            AccountShare accShare = new AccountShare();
            accShare.AccountId = acc.Id;
            accShare.UserOrGroupId = u.Id;
            accShare.AccountAccessLevel = 'Read';
            accShare.ContactAccessLevel = 'Read';
            accShare.OpportunityAccessLevel = 'None';
            accShare.CaseAccessLevel = 'Read';
            accShares.add(accShare);
        }
    }
    if(accShares.size()>0){
        INSERT accShares;
    }
}

public static void contactOppUpdate (List<Account> accList, Map<Id,Account> oldAccMaps){

    Set<Id> accdIds = new Set<Id>();
    
    for(Account acc:accList){
        if(acc.Description != oldAccMaps.get(acc.Id).Description){
            accdIds.add(acc.Id);
         }
    }
    List<Account> accList2 = [SELECT Id, Name, Description, (SELECT Id, Name, Description FROM Contacts), (SELECT Id, Name, Description FROM Opportunities) FROM Account WHERE Id IN :accdIds];
    List<Contact> conUpdateList = new List<Contact>();
    List<Opportunity> oppUpdateList = new List<Opportunity>();
    for(Account acc:accList2){
        List<Contact> conList = acc.Contacts;
        List<Opportunity> oppList = acc.Opportunities;
        if(conList.size()>0){
        for(Contact con:conList){
            con.Description = acc.Description;
            conUpdateList.add(con);
        }
    }
        if(oppList.size()>0){
            for(Opportunity opp:oppList){
            opp.Description = acc.Description;
            oppUpdateList.add(opp);
        }
        
        }
    }
    if(conUpdateList.size()>0){
        UPDATE conUpdateList;
    }
    if(oppUpdateList.size()>0){
        UPDATE oppUpdateList;
    }
}

public static void deleteAccount (Map<Id,Account> oldAccMaps){
    Set<Id> accdIds = oldAccMaps.keySet();
   List<Account> accList2 = [SELECT Id, Name, (SELECT Id FROM Opportunities WHERE StageName != 'Closed Lost') FROM Account WHERE Id IN :accdIds];
    for(Account acc:accList2){
        if(acc.Opportunities.size()> 0){
            Trigger.oldMap.get(acc.id).addError('You can not Delete this Account. Because, it has related Opp stage of which is not Closed Lost');
        }  
     }
}

public static void sendDeleteEmail(List<Account> accList) {
    List<Messaging.SingleEmailMessage> allEmails = new List<Messaging.SingleEmailMessage>();
    Set<Id> accountIds = new Set<Id>();
    for(Account acc:accList){
        accountIds.add(acc.Id);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();//Yeni bir email ornegi olusturduk.
        List<String> emailAddress = new List<String>();//Alici adreslerini tutan list olsurduk
        List<String> emailAddressforCC = new List<String> {'nurata1613@gmail.com'};//Alici adreslerini tutan list olsurduk
        emailAddress.add(UserInfo.getUserEmail());//Alici adresini kullanıcı adresi olarak sectik.
        email.setCcAddresses(emailAddressforCC);//Alici adresi ile beraber gonderilecek olsun.
        email.setToAddresses(emailAddress);
        email.setSubject('An Account is deleted');//Konu bilgisi girdik.
        email.setPlainTextBody('Hi, \n\n '+acc.Name+' Account Has been Deleted');
        allEmails.add(email);
    }
    if (!allEmails.isEmpty()) {
        Messaging.sendEmail(allEmails);
    }
   List<Contact> relatedContacts = [SELECT Email, FirstName FROM Contact WHERE AccountId IN :accountIds AND IsDeleted = TRUE ALL ROWS];
        
   List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    for (Contact contact : relatedContacts) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] { contact.Email });
        email.setSubject('Account Deleted Notification');
        email.setPlainTextBody('Dear ' + contact.FirstName + ',\n\nWe wanted to inform you that the account associated with this email has been deleted.\n\nBest regards');
        emails.add(email);
    }
    
    if (!emails.isEmpty()) {
        Messaging.sendEmail(emails);
    }

}

public static void sendUndeleteEmail(List<Account> undeleteAccs){
    List<Messaging.SingleEmailMessage> allEmails = new List <Messaging.SingleEmailMessage>();
         
         for(Account acc: undeleteAccs){
             Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();//Yeni bir email ornegi olusturduk.
             List<String> emailAddress = new List<String>();//Alici adreslerini tutan list olsurduk
             emailAddress.add(UserInfo.getUserEmail());//Alici adresini kullanıcı adresi olarak sectik.
             email.setToAddresses(emailAddress);
             email.setSubject('An Account is undeleted');
             email.setPlainTextBody('Hi, \n\n '+acc.Name+' Account Has been Undeleted');
             allEmails.add(email);
         }
         if (!allEmails.isEmpty()) {
             Messaging.sendEmail(allEmails);
         }
}
}
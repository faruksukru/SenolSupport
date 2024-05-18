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
        INSERT conList;//After kullandigimiz icin DML kullandık, Contact listi database'e aktardık.
    }  
    if(oppList.size()>0){
        INSERT oppList;
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

}
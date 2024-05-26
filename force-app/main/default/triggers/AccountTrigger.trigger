trigger AccountTrigger on Account (before insert, before update, after insert, after update, before delete, after delete) {

  TriggerControlSetting__c triggerControl = TriggerControlSetting__c.getInstance('Trigger Control'); 
  if (triggerControl != null && triggerControl.IsActive__c) {
    switch on Trigger.operationType {
      when BEFORE_INSERT {
        AccountTriggerHandler.adressCheck(trigger.new);
        AccountTriggerHandler.annualRevenue(trigger.new);
      }
      when BEFORE_UPDATE {
        AccountTriggerHandler.annualRevenue(trigger.new);
      }
      when AFTER_INSERT  {
        AccountTriggerHandler.createContactOpp(trigger.new);
        AccountTriggerHandler.shareAccountsWithUser(Trigger.new);
      }
      when AFTER_UPDATE  {
        AccountTriggerHandler.contactOppUpdate(trigger.new, trigger.oldMap);
      }
      when BEFORE_DELETE  {
        AccountTriggerHandler.deleteAccount(trigger.oldMap);
      }
      when AFTER_DELETE  {
        AccountTriggerHandler.sendDeleteEmail(trigger.old);
      }
      when AFTER_UNDELETE{
        AccountTriggerHandler.sendUndeleteEmail(trigger.new); 
      }
    }
  }


 /* if(trigger.isBefore && trigger.isInsert)
  {
    AccountTriggerHandler.adressCheck(trigger.new);
  }
  if(trigger.isBefore && (trigger.isInsert || trigger.isupdate))
  {
    AccountTriggerHandler.annualRevenue(trigger.new);
  }
  if(trigger.isAfter && trigger.isInsert)
  {
    AccountTriggerHandler.createContactOpp(trigger.new);
    AccountTriggerHandler.shareAccountsWithUser(Trigger.new);
  }
  if(trigger.isAfter && trigger.isUpdate)
  {
    AccountTriggerHandler.contactOppUpdate(trigger.new, trigger.oldMap);
  }
  
  if(trigger.isBefore && trigger.isDelete)
  {
    AccountTriggerHandler.deleteAccount(trigger.oldMap);
  }
  if(trigger.isAfter && trigger.isDelete)
  {
    AccountTriggerHandler.sendDeleteEmail(trigger.old);
  }*/
  }

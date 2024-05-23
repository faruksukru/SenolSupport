trigger AccountTrigger on Account (before insert, before update, after insert, after update, before delete) {
  
    if(trigger.isBefore && trigger.isInsert)
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
  
  }
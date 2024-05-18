trigger AccountTrigger on Account (before insert, before update, after insert, after update) {
  
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
  }
  if(trigger.isAfter && trigger.isUpdate)
  {
    AccountTriggerHandler.contactOppUpdate(trigger.new, trigger.oldMap);
  }
  
  
  }
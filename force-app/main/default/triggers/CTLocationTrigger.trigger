trigger CTLocationTrigger on Location__c (before insert,before update,before delete,after insert, after update, after delete, after undelete) {
    
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            CTLocationTriggerHandler.beforeInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            CTLocationTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }

    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            CTLocationTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}
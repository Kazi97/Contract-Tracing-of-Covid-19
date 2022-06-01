trigger CTPersonTrigger on Person__c (before insert,before update,before delete,after insert, after update, after delete, after undelete) {

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            CTPersonTriggerHandler.beforeInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            CTPersonTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }

    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            CTPersonTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}
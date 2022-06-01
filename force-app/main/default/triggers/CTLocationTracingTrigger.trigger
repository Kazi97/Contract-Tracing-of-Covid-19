trigger CTLocationTracingTrigger on Location_Tracing__c (before insert) {

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            CTLocationTracingTriggerHandler.beforeInsert(Trigger.new);
        }
    }

}
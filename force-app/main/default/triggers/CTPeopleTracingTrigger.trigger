trigger CTPeopleTracingTrigger on People_Tracing__c (before insert) {

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            CTPeopleTracingTriggerHandler.beforeInsert(Trigger.new);
        }
    }
}
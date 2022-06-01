public with sharing class CTLocationTracingTriggerHandler {
    
    public static void beforeInsert(List<Location_Tracing__c> newRecord){
        
        List<Location_Tracing__c> duplicateValues = CTLocationTracingController.checkDuplicates(newRecord);
        for(Location_Tracing__c lt : duplicateValues){
            lt.addError('Duplicate Record');
        }
    }
}
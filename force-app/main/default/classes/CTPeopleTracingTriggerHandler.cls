public with sharing class CTPeopleTracingTriggerHandler {
    
    public static void beforeInsert(List<People_Tracing__c> newRecords){

        List<People_Tracing__c> duplicateValues = CTPeopleTracingController.checkDuplicates(newRecords);
        for(People_Tracing__c pt : duplicateValues){
            Person__c p1 = CTPersonController.getPersonById(pt.Person_1__c);
            Person__c p2 = CTPersonController.getPersonById(pt.Person_2__c);
            pt.addError('Duplicate record found with Person 1 : '+p1.Name+' and Person 2: '+p2.Name);
        }
    }
}
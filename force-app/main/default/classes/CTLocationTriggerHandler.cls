public with sharing class CTLocationTriggerHandler {
    
    public static void beforeInsert(List<Location__c> newRecord){
        for(Location__c l :  newRecord){
            l.Status__c = 'Green';
        }
    }

    public static void beforeUpdate(List<Location__c> newRecord, Map<Id,Location__c> oldMapRecord){
        for(Location__c l :  newRecord){
            if(l.Status__c != oldMapRecord.get(l.Id).Status__c){
                l.Status_Update_Date__c = Date.today();
            }
        }
    }

    public static void afterUpdate(List<Location__c> newRecord, Map<Id,Location__c> oldMapRecord){
        //set to store the location with red status
        Set<Id> location_StatusRed = new Set<Id>();
        for(Location__c l :  newRecord){
            if(l.Status__c == 'Red' && oldMapRecord.get(l.Id).Status__c != 'Red'){
                location_StatusRed.add(l.Id);
            }
        }

        //list to store the person's visited
        List<Location_Tracing__c> locationTraceDetails = CTLocationTracingController.getLocationByLocationIds(location_StatusRed);

        
        Set<Id> personIds = new Set<Id>();
        for(Location_Tracing__c lt : locationTraceDetails){
            personIds.add(lt.Person__c);
        }

        List<Person__c> personsToUpdate = new List<Person__c>();
        for(Id pid : personIds){
            personsToUpdate.add(new Person__c(Id=pid,Health_Status__c='Yellow'));
        }

        if(personsToUpdate != null && personsToUpdate.size()>0){
            update personsToUpdate;
        }
    }
}
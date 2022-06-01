public with sharing class CTPersonTriggerHandler {
    
    public static void beforeInsert(List<Person__c> newRecord){
        for(Person__c p : newRecord){
            p.Health_Status__c = 'Green';
            p.Token__c = CTPersonController.getToken(p.Mobile__c);
        }
    }

    public static void beforeUpdate(List<Person__c> newRecord,Map<Id,Person__c> oldMapRecord){

        for(Person__c p: newRecord){
            if(p.Health_Status__c !=  oldMapRecord.get(p.Id).Health_Status__c){
                p.Status_Update_Date__c = Date.today();
            }
        }
    }

    public static void afterUpdate(List<Person__c> newRecord,Map<Id,Person__c> oldMapRecord){

        Set<Id> person_StatusChange = new Set<Id>();
        Set<Id> person_RedStatusChange = new Set<Id>();

        for(Person__c p : newRecord){
            //storing Ids of those person whose health status is changed to orange or yellow or green
            if(p.Health_Status__c != oldMapRecord.get(p.Id).Health_Status__c){
                person_StatusChange.add(p.Id);
            }

            //storing Ids of those person whose health status is changed to red
            if(p.Health_Status__c == 'Red' && oldMapRecord.get(p.Id).Health_Status__c != 'Red'){
                person_RedStatusChange.add(p.Id);
            }
        }

        //set to store all the processedIds
        Set<Id> alreadyProcessed = new Set<Id>();
        alreadyProcessed.addAll(person_RedStatusChange);

        //Set to store the Ids of the persons whose HealthStatus we need to change
        Set<Id> orangeStatus = new Set<Id>();
        Set<Id> yellowStatus = new Set<Id>();

        orangeStatus.addAll(CTPersonController.getCohabitantsList(person_RedStatusChange,alreadyProcessed));
        Set<Id> primaryContactList = CTPersonController.getPrimaryContactList(person_RedStatusChange,alreadyProcessed);
        orangeStatus.addAll(primaryContactList);

        yellowStatus.addAll(CTPersonController.getNeighbourList(person_RedStatusChange,alreadyProcessed));
        yellowStatus.addAll(CTPersonController.getSecondaryContactList(primaryContactList,alreadyProcessed));

        System.debug(CTPersonController.getPrimaryContactList(person_RedStatusChange,alreadyProcessed));
        // System.debug('Secondary', )

        //list of those persons which needs to be updated.
        List<Person__c> personToUpdate = new List<Person__c>();
        for(Id p : orangeStatus){
            personToUpdate.add(new Person__c(Id = p, Health_Status__c = 'Orange'));
        }
        for(Id p : yellowStatus){
            personToUpdate.add(new Person__c(Id = p, Health_Status__c = 'Yellow'));
        }

        if(personToUpdate.size() > 0){
            update personToUpdate;
        }

        List<Location_Tracing__c> locationTraces = CTLocationTracingController.getLocationByPersonIds(person_StatusChange);
        if(locationTraces != null && locationTraces.size()>0){
            Set<Id> locationIds = new Set<Id>();
            for(Location_Tracing__c lt : locationTraces){
                locationIds.add(lt.Location__c);
            }
            CTLocationController.updateRedScore(locationIds);
        }        
    }
}
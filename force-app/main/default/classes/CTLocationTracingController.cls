/**
 * CTLocationTracingController class
 * main controller class for Location_Tracing__c object
 */
public with sharing class CTLocationTracingController {

    public static List<Location_Tracing__c> getVisitors(String locationId){

        /**
         * gets last 30 days visitors
         */
        return [SELECT Id, Person__c, Location__c, Visit_Date__c, Person__r.Token__c, Person__r.Health_Status__c 
                FROM Location_Tracing__c 
                WHERE Id = :locationId
                ORDER BY Visit_Date__c DESC];
    }

    /**
     * gets all locations id for visitors
     */

    public static List<Location_Tracing__c> getLocationByPersonIds(Set<Id> personIds){

        return [SELECT Id, Person__c, Location__c
                FROM Location_Tracing__c 
                WHERE Person__c IN :personIds 
                AND Visit_Date__c = LAST_N_DAYS:10];
    }

    /**
     * Gets all visitors Id  for Locations
     */
    public static List<Location_Tracing__c> getLocationByLocationIds(Set<Id> locationIds){

        return [SELECT Id, Person__c, Location__c
                FROM Location_Tracing__c 
                WHERE Location__c IN :locationIds
                AND Person__r.Health_Status__c = 'Green' 
                AND Visit_Date__c = LAST_N_DAYS:10];
    }

    public static List<Location_Tracing__c> checkDuplicates(List<Location_Tracing__c> newLocationTraces){

        //store unique location and person ids
        Set<Id> locationIds = new Set<Id>();
        Set<Id> personIds = new Set<Id>();

        for(Location_Tracing__c trace : newLocationTraces){
            locationIds.add(trace.Location__c);
            personIds.add(trace.Person__c);
        }

        //map of location id,set of person id
        Map<Id, Set<Id>> mapOfExistingRecords = new Map<Id, Set<Id>>();

        
        //Query existing location tracing records
        List<Location_Tracing__c> existingRecords = [SELECT Id, Person__c, Location__c
                                                    FROM Location_Tracing__c 
                                                    WHERE Person__c IN :personIds 
                                                    AND Location__c IN :locationIds];

        //list of duplicate records.
        List<Location_Tracing__c> duplicates = new List<Location_Tracing__c>();
        
        
        if(existingRecords != null && existingRecords.size() > 0){
            for(Location_Tracing__c trace : existingRecords){
                if(! mapOfExistingRecords.containsKey(trace.Location__c)){
                    mapOfExistingRecords.put(trace.Location__c, new Set<Id>());
                }
                //add personId to map set
                mapOfExistingRecords.get(trace.Location__c).add(trace.Person__c);
            }

            //loop over new Location tracing records
            for(Location_Tracing__c trace : newLocationTraces){
                if(mapOfExistingRecords.containsKey(trace.Location__c) && mapOfExistingRecords.get(trace.Location__c).contains(trace.Person__c)){
                    duplicates.add(trace);
                }
            }
        }

        return duplicates;
    }
}
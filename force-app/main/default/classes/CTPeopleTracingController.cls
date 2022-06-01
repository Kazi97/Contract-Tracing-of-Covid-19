/**
 * CTLocationTracingController class
 * main controller class for People_Tracing__c object
 */
public with sharing class CTPeopleTracingController {

    public static List<People_Tracing__c> getTraces(String personId){

        return [SELECT Id, Name, Contact_Date__c, Contact_Type__c, Person_1__c, Person_1__r.Health_Status__c, Person_1__r.Token__c, Person_2__c, Person_2__r.Health_Status__c, Person_2__r.Token__c
        FROM People_Tracing__c 
        WHERE (Person_1__c = :personId 
        OR Person_2__c = :personId)
        AND Contact_Date__c = LAST_N_DAYS:30
        ORDER BY Contact_Date__c DESC];
    }

    public static List<People_Tracing__c> checkDuplicates(List<People_Tracing__c> peopleTraces){

        //Store unique personIds
        Set<Id> personIds = new Set<Id>();

        for (People_Tracing__c person : peopleTraces){
            personIds.add(person.Person_1__c);
            personIds.add(person.Person_2__c);
        }

        Map<Id, Set<Id>> mapOfExistingRecords = new Map<Id, Set<Id>>();

        List<People_Tracing__c> existingRecords = [SELECT Id,  Person_1__c, Person_2__c
        FROM People_Tracing__c 
        WHERE Person_1__c = :personIds 
        OR Person_2__c = :personIds];

        //list to store Duplicate id
        List<People_Tracing__c> duplicateRecords = new List<People_Tracing__c>();

        if (existingRecords != null && existingRecords.size() > 0) {
            for(People_Tracing__c person : existingRecords){

                //build map for Person 1
                if (! mapOfExistingRecords.containsKey(person.Person_1__c)) {
                    mapOfExistingRecords.put(person.Person_1__c, new Set<Id>());
                }
                //add person 2 ids inside the map 
                mapOfExistingRecords.get(person.Person_1__c).add(person.Person_2__c);

                //build map for Person 2
                if (! mapOfExistingRecords.containsKey(person.Person_2__c)) {
                    mapOfExistingRecords.put(person.Person_2__c, new Set<Id>());
                }
                //add person 1 ids inside the map 
                mapOfExistingRecords.get(person.Person_2__c).add(person.Person_1__c);
            }

            for (People_Tracing__c person : peopleTraces) {
                if (
                    (mapOfExistingRecords.containsKey(person.Person_1__c) & mapOfExistingRecords.get(person.Person_1__c).contains(person.Person_2__c))  
                    ||
                    (mapOfExistingRecords.containsKey(person.Person_2__c) & mapOfExistingRecords.get(person.Person_2__c).contains(person.Person_1__c))
                ){
                    duplicateRecords.add(person);                
                }            
            }
        }
        return duplicateRecords;
    }
}
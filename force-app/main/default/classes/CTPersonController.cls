/**
 * main controller class for Percon__c object
 */
public with sharing class CTPersonController {
    
    /**
     * generating a unique token from mobile no
     * using MD5 hashing (one way hasing)
     */
    public static String getToken(String mobile){

        Blob targetValue = Blob.valueOf(mobile);
        Blob hash = Crypto.generateDigest('MD5', targetValue);

        return EncodingUtil.base64Encode(hash);
    }

    /**
     * getting 100 contacts with recent health changes 
     */
    @AuraEnabled(cacheable=true)
    public static List<Person__c> getRecentHealthChanges(){

        return [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c 
                        FROM Person__c ORDER BY Status_Update_Date__c DESC NULLS LAST LIMIT 100];
    }

    /**
     * getting list of person according to a desired search term
     */
    @AuraEnabled(cacheable=true)
    public static List<Person__c> searchPerson(String searchTerm){

        if(searchTerm != NULL || searchTerm != ''){
            searchTerm = searchTerm + '%';
            return [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c 
                                FROM Person__c WHERE NAME LIKE :searchTerm 
                                OR Mobile__c LIKE :searchTerm 
                                OR Token__c LIKE :searchTerm 
                                ORDER BY Status_Update_Date__c DESC NULLS LAST];
        }
        else{
            CTPersonController.getRecentHealthChanges();
        }  
        return null;      
    }

    /**
     * getting all the detail of a person by Id 
     */
    @AuraEnabled(cacheable=true)
    public static Person__c getPersonById(String personId){

        List<Person__c> people =  [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c 
                                    FROM Person__c WHERE Id = :personId];

        if (people != null && people.size() > 0){
            return people[0];
        }
        return null;
    }

    /**
     * getting count of people in each health status 
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Integer> getHealthStatusCount(){

        Map<String, Integer> healthCountMap = new Map<String, Integer>();

        for(AggregateResult ar : [SELECT  COUNT(Id) total, Health_Status__c 
                                    FROM Person__c GROUP BY Health_Status__c]){
            healthCountMap.put(String.valueOf(ar.get('Health_Status__c')), Integer.valueOf(ar.get('total')));
        }
        return healthCountMap;
    }

    /**
     * Getting the list of cohabitants
     */
    public static Set<Id> getCohabitantsList(Set<Id> personIds, Set<Id> alreadyProcessedIds){

        List<String> healthStatus = new List<String>{'Green','Yellow'};
        List<People_Tracing__c> peopleTraces = [SELECT Person_1__c, Person_2__c FROM People_Tracing__c
                                                    WHERE (Person_1__c IN: personIds OR Person_2__c IN: personIds)
                                                    AND Contact_Type__c = 'Cohabitant' 
                                                    AND (Person_1__r.Health_Status__c IN: healthStatus OR Person_2__r.Health_Status__c IN: healthStatus)];

        Set<Id> cohabitantList = new Set<Id>();
        for(People_Tracing__c pt : peopleTraces){
            if(!alreadyProcessedIds.contains(pt.Person_1__c)){
                cohabitantList.add(pt.Person_1__c);
                alreadyProcessedIds.add(pt.Person_1__c);
            }
            if(!alreadyProcessedIds.contains(pt.Person_2__c)){
                cohabitantList.add(pt.Person_2__c);
                alreadyProcessedIds.add(pt.Person_2__c);
            }
        }

        return cohabitantList;
    }

    /**
     * Getting the list of neighbours
     */
    public static Set<Id> getNeighbourList(Set<Id> personIds, Set<Id> alreadyProcessedIds){

        // List<String> healthStatus = new List<String>{'Green','Yellow'};
        List<People_Tracing__c> peopleTraces = [SELECT Person_1__c, Person_2__c FROM People_Tracing__c
                                                    WHERE (Person_1__c IN: personIds OR Person_2__c IN: personIds)
                                                    AND Contact_Type__c = 'Neighbour' 
                                                    AND (Person_1__r.Health_Status__c = 'Green' OR Person_2__r.Health_Status__c = 'Green')];

        Set<Id> neighbourList = new Set<Id>();
        for(People_Tracing__c pt : peopleTraces){
            if(!alreadyProcessedIds.contains(pt.Person_1__c)){
                neighbourList.add(pt.Person_1__c);
                alreadyProcessedIds.add(pt.Person_1__c);
            }
            if(!alreadyProcessedIds.contains(pt.Person_2__c)){
                neighbourList.add(pt.Person_2__c);
                alreadyProcessedIds.add(pt.Person_2__c);
            }
        }

        return neighbourList;
    }

    /**
     * Getting the list of primary contacts
     */
    public static Set<Id> getPrimaryContactList(Set<Id> personIds, Set<Id> alreadyProcessedIds){

        List<String> healthStatus = new List<String>{'Green','Yellow'};
        List<People_Tracing__c> peopleTraces = [SELECT Person_1__c, Person_2__c FROM People_Tracing__c
                                                    WHERE (Person_1__c IN: personIds OR Person_2__c IN: personIds)
                                                    AND Contact_Type__c = 'Other' 
                                                    AND Contact_Date__c = LAST_N_DAYS:10
                                                    AND (Person_1__r.Health_Status__c IN: healthStatus OR Person_2__r.Health_Status__c IN: healthStatus)];

        Set<Id> primaryContactList = new Set<Id>();
        for(People_Tracing__c pt : peopleTraces){
            if(!alreadyProcessedIds.contains(pt.Person_1__c)){
                primaryContactList.add(pt.Person_1__c);
                alreadyProcessedIds.add(pt.Person_1__c);
            }
            if(!alreadyProcessedIds.contains(pt.Person_2__c)){
                primaryContactList.add(pt.Person_2__c);
                alreadyProcessedIds.add(pt.Person_2__c);
            }
        }

        return primaryContactList;
    }

    /**
     * Getting the list of secondary contacts
     */
    public static Set<Id> getSecondaryContactList(Set<Id> primaryContactIds, Set<Id> alreadyProcessedIds){

        // List<String> healthStatus = new List<String>{'Green','Yellow'};
        List<People_Tracing__c> peopleTraces = [SELECT Person_1__c, Person_2__c FROM People_Tracing__c
                                                    WHERE (Person_1__c IN: primaryContactIds OR Person_2__c IN: primaryContactIds)
                                                    AND Contact_Type__c = 'Other' 
                                                    AND Contact_Date__c = LAST_N_DAYS:10
                                                    AND (Person_1__r.Health_Status__c = 'Green' OR Person_2__r.Health_Status__c = 'Green')];

        Set<Id> secondaryContactList = new Set<Id>();
        for(People_Tracing__c pt : peopleTraces){
            if(!alreadyProcessedIds.contains(pt.Person_1__c)){
                secondaryContactList.add(pt.Person_1__c);
                alreadyProcessedIds.add(pt.Person_1__c);
            }
            if(!alreadyProcessedIds.contains(pt.Person_2__c)){
                secondaryContactList.add(pt.Person_2__c);
                alreadyProcessedIds.add(pt.Person_2__c);
            }
        }

        return secondaryContactList;
    }
}
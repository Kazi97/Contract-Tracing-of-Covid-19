/**
 * CTLocationController
 * Main controller class for Location__c object
 */

public with sharing class CTLocationController {
    
    
    /**
     * getting 100 locations with recent status changes 
     */
    @AuraEnabled(cacheable=true)
    public static List<Location__c> getRecentStatusChanges(){

        return [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c 
                FROM Location__c ORDER BY Status_Update_Date__c DESC NULLS LAST LIMIT 100];
    }

    /**
     * getting list of locations according to a desired search term
     */
    @AuraEnabled(cacheable=true)
    public static List<Location__c> searchLocations(String searchTerm){

        if(searchTerm != NULL || searchTerm != ''){
            searchTerm = searchTerm + '%';

            return [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c FROM Location__c 
                    WHERE Name LIKE :searchTerm
                    OR Pincode__c LIKE :searchTerm
                    OR Address__c LIKE :searchTerm
                    ORDER BY Status_Update_Date__c DESC NULLS LAST];
        }else{
            CTLocationController.getRecentStatusChanges();
        }

        return null;
    }

    /**
     * getting all the detail of a location by Id 
     */
    @AuraEnabled(cacheable=true)
    public static Location__c getLocationById(String locationId){

        List<Location__c> locations = [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c 
                                        FROM Location__c WHERE Id = :locationId];

        if (locations != null && locations.size() > 0){

            return locations[0];
        }
        return null;
    }

    /**
     * getting count of locations in each Status
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Integer> getStatusCount(){

        Map<String, Integer> healthCountMap = new Map<String, Integer>();

        for(AggregateResult ar : [SELECT COUNT(Id) total, Status__c 
                                    FROM Location__c GROUP BY Status__c]){
            healthCountMap.put(String.valueOf(ar.get('Status__c')), Integer.valueOf(ar.get('total')));
        }

        return healthCountMap;
    }

    public static void updateRedScore(Set<Id> locationIds){
        List<Location__c> locationsToUpdate = new List<Location__c>();

        AggregateResult [] redPeoplePerLocation = [SELECT Location__c, COUNT(Id)total FROM Location_Tracing__c
                                                    WHERE Location__c IN: locationIds
                                                    AND Person__r.Health_Status__c = 'Red'
                                                    AND Visit_Date__c = LAST_N_DAYS:10
                                                    GROUP BY Location__c];

        for(AggregateResult r : redPeoplePerLocation){
            String locationId = String.valueOf(r.get('Location__c'));
            Integer redScore = Integer.valueOf(r.get('total'));
            String status = getStatus(redScore);

            locationsToUpdate.add(new Location__c(Id = locationId,Red_Score__c = redScore,Status__c = status));
        }

        if(locationsToUpdate != null && locationsToUpdate.size() > 0){
            update locationsToUpdate;
        }
    }

    public static String getStatus(Integer redScore){

        if(redScore == 0){
            return 'Green';
        }else if(redScore <= 5){
            return 'Yellow';
        }else if(redScore <= 10){
            return 'Orange';
        }else {
            return 'Red';
        }
    }
}
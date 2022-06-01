public with sharing class ContactTriggerHandler {
    
    public static void afterInsertHandler(List<Contact> newContacts){

        Set<Id> accountIds = new Set<Id>();
        for(Contact con : newContacts){

            if(String.isNotBlank(con.AccountId)){
                accountIds.add(con.AccountId);
            }
        }

        AccountContactService.updateActiveContacts(accountIds);
    }
    
    public static void afterUpdateHandler(List<Contact> newContacts, Map<Id,Contact> oldContactMap){

        Set<Id> accountIds = new Set<Id>();
        for(Contact con : newContacts){

            if(String.isNotBlank(con.AccountId) && oldContactMap.get(con.Id).Active__c != con.Active__c){
                accountIds.add(con.AccountId);
            }
            else if(oldContactMap.get(con.Id).AccountId != con.AccountId){
                accountIds.add(con.AccountId);
                accountIds.add(oldContactMap.get(con.Id).AccountId);
            }
        }

        AccountContactService.updateActiveContacts(accountIds);
    }

    public static void afterDeleteHandler(List<Contact> oldContacts){

        Set<Id> accountIds = new Set<Id>();
        for(Contact con : oldContacts){

            if(String.isNotBlank(con.AccountId)){
                accountIds.add(con.AccountId);
            }
        }

        AccountContactService.updateActiveContacts(accountIds);
    }

    public static void afterUpdateHandler(List<Contact> newContacts){

        Set<Id> accountIds = new Set<Id>();
        for(Contact con : newContacts){

            if(String.isNotBlank(con.AccountId)){
                accountIds.add(con.AccountId);
            }
        }

        AccountContactService.updateActiveContacts(accountIds);
    }
}
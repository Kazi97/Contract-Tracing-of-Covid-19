trigger ContactTrigger on Contact (after insert, after update, after delete, after undelete) {

    switch on Trigger.operationType {
        when AFTER_INSERT {
            
            ContactTriggerHandler.afterInsertHandler(Trigger.new);
        }

        when AFTER_UPDATE{

            ContactTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap);
        }

        when AFTER_DELETE{

            ContactTriggerHandler.afterInsertHandler(Trigger.old);
            
        }

        when AFTER_UNDELETE{

            ContactTriggerHandler.afterInsertHandler(Trigger.new);

        }
    }





    
    /*
    if(Trigger.isAfter){
        List<Account> updateField = new List<Account>();

        for(Contact con : Trigger.new){

            List<Contact> contactCount = [SELECT Id FROM Contact WHERE con.Active__c = 'TRUE'];
            updateField.add(new Account(Id = con.AccountId, Active_Contacts__c = contactCount.size()));
        }

        update updateField;
    }
    */

}
public with sharing class CTUserTabController {
    
    @AuraEnabled
    public static PersonInfoWrapper getPersonDetails(String recordId){

        Set<Id> uniqueId = new Set<Id>();
        uniqueId.add(recordId);
        PersonInfoWrapper personInfo = new PersonInfoWrapper();

        Person__c person = CTPersonController.getPersonById(recordId);
        if(person != null){
            personInfo.name = person.Name;
            personInfo.healthStatus = person.Health_Status__c;
            personInfo.mobile = person.Mobile__c;
            personInfo.statusUpdateDate = person.Status_Update_Date__c;
            personInfo.token = person.Token__c;
        }

        List<People_Tracing__c> traces = CTPeopleTracingController.getTraces(recordId);
        if(traces != null && traces.size() > 0){
            List<CloseContact> closeContactList = new List<CloseContact>();
            for(People_Tracing__c trace : traces){
                CloseContact cc = new CloseContact();
                if(!uniqueId.contains(trace.Person_1__c)){
                    cc.id = trace.Person_1__c;
                    cc.token = trace.Person_1__r.Token__c;
                    cc.contactDate = trace.Contact_Date__c;
                    cc.healthStatus = trace.Person_1__r.Health_Status__c;
                }if(!uniqueId.contains(trace.Person_2__c)){
                    cc.id = trace.Person_2__c;
                    cc.token = trace.Person_2__r.Token__c;
                    cc.contactDate = trace.Contact_Date__c;
                    cc.healthStatus = trace.Person_2__r.Health_Status__c;
                }
                closeContactList.add(cc);
            }
            personInfo.closecontact = closeContactList;
            personInfo.noOfContact = closeContactList.size();
        }
        return personInfo;
    }

    public class PersonInfoWrapper{
        @AuraEnabled public String name;
        @AuraEnabled public String healthStatus;
        @AuraEnabled public String mobile;
        @AuraEnabled public Date statusUpdateDate;
        @AuraEnabled public String token;
        @AuraEnabled public Integer noOfContact = 0;
        @AuraEnabled public List<CloseContact> closecontact;
    }    
    public class CloseContact{
        @AuraEnabled public String id;
        @AuraEnabled public String token;
        @AuraEnabled public Date contactDate;
        @AuraEnabled public String healthStatus;
    }
}

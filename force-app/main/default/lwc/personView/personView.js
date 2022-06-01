import { LightningElement, track, wire } from 'lwc';
import getHealthStatusCount from '@salesforce/apex/CTPersonController.getHealthStatusCount';
import getRecentHealthChanges from '@salesforce/apex/CTPersonController.getRecentHealthChanges';
import searchPerson from '@salesforce/apex/CTPersonController.searchPerson';
import { NavigationMixin } from 'lightning/navigation';
import contactTracingChannel from '@salesforce/messageChannel/ContactTracing__c';
import { publish,MessageContext } from 'lightning/messageService';

const columns = [
    { label: 'Name', fieldName: 'Name', type: 'text' },
    { label: 'Phone', fieldName: 'Mobile__c', type: 'phone' },
    { label: 'Token', fieldName: 'Token__c', type: 'text' },
    { label: 'Status', fieldName: 'Health_Status__c', type: 'text' },
    { label: 'Status Update Date', fieldName: 'Status_Update_Date__c', type: 'date' },
    {
        label: 'View', type: 'button', fixedWidth: 150, typeAttributes: {
            label: 'View/Update'
        }
    }
];

export default class PersonView extends NavigationMixin(LightningElement) {

    @track columns = columns
    @track person_green
    @track person_yellow
    @track person_orange
    @track person_red
    @track person_healthData
    @track searchTerm

    @wire(getHealthStatusCount)
    personStatus({ data, error }) {
        if (data) {
            this.person_green = data.Green
            this.person_yellow = data.Yellow
            this.person_orange = data.Orange
            this.person_red = data.Red
        } else if (error) {
            console.log(error)
        }
    }

    @wire(getRecentHealthChanges)
    personHealthChanges({ data, error }) {
        if (data) {
            this.person_healthData = data
        } else if (error) {
            console.log(error)
        }
    }

    searchPeopleHandler(event){
        this.searchTerm = event.target.value
    }

    @wire(searchPerson, {searchTerm : '$searchTerm'})
    person({data,error}){
        if(data){
            this.person_healthData = data
        }else if(error){
            console.log(error)
        }
    }

    newPersonHadler() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Person__c',
                actionName: 'new'
            }
        })
    }

    @wire(MessageContext)messageContext

    handleChange(event){
        console.log(event.detail.row.Id)

        publish(
            this.messageContext,
            contactTracingChannel,
            {personId : event.detail.row.Id, message: 'person'}
        )
    }
}
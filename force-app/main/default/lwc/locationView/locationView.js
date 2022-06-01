import { LightningElement, track, wire } from 'lwc';
import getStatusCount from '@salesforce/apex/CTLocationController.getStatusCount';
import getRecentStatusChanges from '@salesforce/apex/CTLocationController.getRecentStatusChanges';
import searchLocations from '@salesforce/apex/CTLocationController.searchLocations';
import { NavigationMixin } from 'lightning/navigation';
import contactTracingChannel from '@salesforce/messageChannel/ContactTracing__c';
import { publish,MessageContext } from 'lightning/messageService';

const columns = [
    { label: 'Name', fieldName: 'Name', type: 'text' },
    { label: 'Address', fieldName: 'Address__c', type: 'text' },
    { label: 'Pincode', fieldName: 'Pincode__c' },
    { label: 'Red Score', fieldName: 'Red_Score__c', type: 'number' },
    { label: 'Status', fieldName: 'Status__c', type: 'text' },
    { label: 'Status Update Date', fieldName: 'Status_Update_Date__c', type: 'date' },
    {
        label: 'View', type: 'button', fixedWidth: 150, typeAttributes: {
            label: 'View/Update'
        }
    }
];

export default class LocationView extends NavigationMixin(LightningElement) {

    @track columns = columns
    @track location_green
    @track location_yellow
    @track location_orange
    @track location_red
    @track location_healthData
    @track searchTerm

    @wire(getStatusCount)
    locationStatus({data,error}){
        if(data){
            this.location_green = data.Green
            this.location_yellow = data.Yellow
            this.location_orange = data.Orange
            this.location_red = data.Red
        }else if(error){
            console.log(error)
        }
    }

    @wire(getRecentStatusChanges)
    locationHealthChanges({data,error}){
        if(data){
            this.location_healthData = data
        }else if (error){
            console.log(error)
        }
    }

    searchLocationHandler(event){
        this.searchTerm = event.target.value
    }

    @wire(searchLocations, {searchTerm : '$searchTerm'})
    location({data,error}){
        if(data){
            this.location_healthData = data
        }else if(error){
            console.log(error)
        }
    }

    newLocationHandler() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Location__c',
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
            {locationId : event.detail.row.Id, message : 'location'}
        )
    }
}
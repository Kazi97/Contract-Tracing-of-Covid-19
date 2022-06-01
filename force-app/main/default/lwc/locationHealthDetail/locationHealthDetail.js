import { api, LightningElement, track, wire } from 'lwc';
import getLocationById from '@salesforce/apex/CTLocationController.getLocationById';

export default class LocationHealthDetail extends LightningElement {

    @api locationId
    @track name
    @track address
    @track pincode
    @track status 
    @track redScore
    @track statusUpdateDate
    @track backgroundColor
    @track location = false

    @wire(getLocationById, {locationId : '$locationId'})
    locationDetails({data,error}){
        if(data){
            console.log(data)
            this.name = data.Name
            this.address = data.Address__c
            this.pincode = data.Pincode__c
            this.status = data.Status__c
            this.redScore = data.Red_Score__c
            this.statusUpdateDate = data.Status_Update_Date__c
            if(this.status === 'Red'){
                this.backgroundColor = 'Red'
            }else if(this.status === 'Yellow'){
                this.backgroundColor = 'Yellow'
            }else if(this.status === 'Orange'){
                this.backgroundColor = 'Orange'
            }else if(this.status === 'Green'){
                this.backgroundColor = 'Green'
            }
            this.location = true
        }else if(error){
            console.error(error.body.message)
        }
    }
}
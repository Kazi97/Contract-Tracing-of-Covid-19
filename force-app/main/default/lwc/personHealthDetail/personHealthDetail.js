import { api, LightningElement, track, wire } from 'lwc';
import getPersonById from '@salesforce/apex/CTPersonController.getPersonById';

export default class PersonHealthDetail extends LightningElement {

    @api personId
    @track name
    @track mobile
    @track token
    @track healthStatus 
    @track statusUpdateDate
    @track backgroundColor
    @track person = false

    @wire(getPersonById, {personId : '$personId'})
    personDetails({data,error}){
        if(data){
            console.log(data)
            this.name = data.Name
            this.mobile = data.Mobile__c
            this.token = data.Token__c
            this.healthStatus = data.Health_Status__c
            this.statusUpdateDate = data.Status_Update_Date__c
            if(this.healthStatus === 'Red'){
                this.backgroundColor = 'Red'
            }else if(this.healthStatus === 'Yellow'){
                this.backgroundColor = 'Yellow'
            }else if(this.healthStatus === 'Orange'){
                this.backgroundColor = 'Orange'
            }else if(this.healthStatus === 'Green'){
                this.backgroundColor = 'Green'
            }
            this.person = true
        }else if(error){
            console.error(error.body.message)
        }
    }

    get statusColor(){
        if(this.healthStatus != 'Red'){
            return true
        }
        return false
    }
}
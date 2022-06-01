import { LightningElement, track } from 'lwc';
import getPersonDetails from '@salesforce/apex/CTUserTabController.getPersonDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
    {label: 'Id', fieldName: 'id', type: 'text'},
    {label: 'Token', fieldName: 'token', type: 'text'},
    {label: 'Health Status', fieldName: 'healthStatus', type: 'text'},
    {label: 'Contact Date', fieldName: 'contactDate', type: 'date'}
]
export default class CtUserTab extends LightningElement {
    @track columns = columns
    @track personId
    @track personData
    @track contactData
    @track modalOpen = false

    inputUserHandler(event){
        if(event.target.value != null)
        this.personId = event.target.value;
    }

    searchUserHandler(){
        getPersonDetails({
            recordId : this.personId
        }).then(result => {
            console.log(result)
            this.personData = result
            this.contactData = result.closecontact
            if(this.personData.healthStatus === 'Red'){
                this.backgroundColor = 'Red'
            }else if(this.personData.healthStatus === 'Yellow'){
                this.backgroundColor = 'Yellow'
            }else if(this.personData.healthStatus === 'Orange'){
                this.backgroundColor = 'Orange'
            }else if(this.personData.healthStatus === 'Green'){
                this.backgroundColor = 'Green'
            }
            this.modalOpen = true
        }).catch(err => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Enter valid user Id',
                message: 'ERROR',
                variant: error
            }))
            console.error(err)

        })

        this.template.querySelectorAll('lightning-input').forEach(element => element.value = '')
    }

    closeModal(){
        this.modalOpen = false
    }
}
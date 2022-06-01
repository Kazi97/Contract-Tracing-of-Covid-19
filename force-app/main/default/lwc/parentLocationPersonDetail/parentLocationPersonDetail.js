import { api, LightningElement, track, wire } from 'lwc';
import contactTracingChannel from '@salesforce/messageChannel/ContactTracing__c';
import { subscribe,unsubscribe,MessageContext,APPLICATION_SCOPE } from 'lightning/messageService';


export default class ParentLocationPersonDetail extends LightningElement {

    @api personId
    @api locationId
    @track person = false
    @track location = false
    @track subscribtion = null

    connectedCallback(){
        this.subscribeChannel()
    }

    @wire(MessageContext)messagingContext

    subscribeChannel(){
        if(this.subscribtion == null){
            this.subscribtion = subscribe(
                this.messagingContext,
                contactTracingChannel,
                (message)=>this.handleMessage(message),
                {scope : APPLICATION_SCOPE}
            )
        }
    }

    handleMessage(message){
        if(message.message === 'person'){
            this.location = false
            this.personId = message.personId
            this.person = true
        }else if(message.message === 'location'){
            this.person = false
            this.locationId = message.locationId
            this.location = true
        }
    }

    disconnectedCallback(){
        this.unsubscribeChannel();
    }

    unsubscribeChannel(){
        unsubscribe(this.subscribtion)
        this.subscribtion = null
    }
    
}
({
    clickBlockHandler : function(component, event, helper) {
        let open = component.get("v.open")
        if(!open){
            component.set("v.open", true)
            //get label value
            const label = component.get("v.label")
            //fire the block click event
            let compEvt = component.getEvent("onclick")
            compEvt.setParams({"value" : label})
            compEvt.fire();
        }
    }
})
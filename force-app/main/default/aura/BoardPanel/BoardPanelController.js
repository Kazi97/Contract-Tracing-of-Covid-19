({
    startGame : function(component, event, helper) {
        //access the combobox component
        let gameModeComboBox = component.find("gameMode")

        //access the value of combobox
        let selectedValue = gameModeComboBox.get("v.value")

        //setting the value to a new variable
        component.set("v.selectedValue",selectedValue)
        // console.log(`From BoardPanel ${selectedValue}`)
    },
})
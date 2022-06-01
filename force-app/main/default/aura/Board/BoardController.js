({
    doInit: function (component, event, helper) {
        // console.log(`doInit function called`)
        let column = 0
        let gameMode = component.get("v.mode")
        if (gameMode && gameMode === 'hard') {
            column = 6
        } else if (gameMode === 'medium') {
            column = 4
        } else {
            column = 3
        }
        component.set("v.blockSize", (12 / column))

        //get an array of n number of words from an array of 100 words
        const wordList = helper.getWords(column * column)
        component.set("v.wordList", wordList);

        //get an random win word from the array of n words.
        const winWord = helper.getWinWord(wordList)
        component.set("v.winWord", winWord);
    },

    blockClickHandler: function (component, event, helper) {

        let clickCount = component.get("v.clickCount") + 1

        //get event value
        const value = event.getParam("value")
        if (value === component.get("v.winWord")) {
            //user won
            component.set("v.result", "YOU WON")
            console.log('YOU WON')
            helper.disableBoard(component)
        } else if (clickCount === 3) {
            // user lost
            component.set("v.result", "YOU LOST")
            console.log('YOU LOST')
            helper.disableBoard(component)
        }

        //set click count
        component.set("v.clickCount", clickCount)
    }
})
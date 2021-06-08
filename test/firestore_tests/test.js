const assert = require('assert');
const firebase = require('@firebase/testing');

const PROJECT_ID = "stopor-f035c";

describe("Stopor", () => {
    it("Can read from database", async () => {
        const db = firebase.initializeTestApp({projectId: PROJECT_ID}).firestore();
        const testDoc = db.collection("events").doc("8mmADItdmqSk5Lxa5u5k");
        await firebase.assertSucceeds(testDoc.get());
    })
})
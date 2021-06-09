const assert = require('assert');
const firebase = require('@firebase/rules-unit-testing');

const PROJECT_ID = "stopor-f035c";
const USER =  { uid: "speedypleath", email: "speedypleath@example.com" };
const ANOTHER_USER = { uid: "another", email: "speedypleath@example.com" };

function getFirestore(auth){
    return firebase.initializeTestApp({ projectId: PROJECT_ID, auth: auth }).firestore();
}

describe("Authentication", () => {
    it("Can't read from database if not authenticated", async () => {
        const db = getFirestore();
        const testDoc = db.collection("randomCollection").doc("testDoc");
        await firebase.assertFails(testDoc.get());
    });

    it("Can't write to database if not authenticated", async () => {
        const db = firebase.initializeTestApp({ projectId: PROJECT_ID }).firestore();
        const testDoc = db.collection("randomCollection").doc("testDoc");
        await firebase.assertFails(testDoc.set({ foo: "bar" }));
    });

    it("Can read from database if authenticated", async () => {
        const db = getFirestore(USER);
        const testDoc = db.collection("randomCollection").doc("testDoc");
        const userDoc = db.collection("users").doc("speedypleath");
        await firebase.assertSucceeds(userDoc.set({userId: "speedypleath"}));
        await firebase.assertSucceeds(testDoc.get());
    });

    after(async () => {
        const db = getFirestore(USER);
        const testDoc = db.collection("users").doc("speedypleath");
        await testDoc.delete();
    });
});

describe("Users", () => {
    it("Can write user if it does correspond to authenticated user", async () => {
        const db = getFirestore(USER);
        const testDoc = db.collection("users").doc("speedypleath");
        await firebase.assertSucceeds(testDoc.set({userId: "speedypleath"}));
    });

    it("Can't write user if it doesn't correspond to authenticated user", async () => {
        const db = getFirestore(USER);
        const testDoc = db.collection("users").doc("anotherTestDoc");
        await firebase.assertFails(testDoc.set({ userId: "foo" }));
    });

    it("Can't modify user if it doesn't correspond to authenticated user", async () => {
        const db = getFirestore(ANOTHER_USER);
        const testDoc = db.collection("users").doc("speedypleath");
        await firebase.assertFails(testDoc.update({ userId: "speedypleath" }));
    });

    it("Can modify user if it does correspond to authenticated user", async () => {
        const db = getFirestore(USER);
        const testDoc = db.collection("users").doc("speedypleath");
        await firebase.assertSucceeds(testDoc.update({ bar: "foo", userId: "speedypleath"}));
    });

    it("Can't delete user if it doesn't correspond to authenticated user", async () => {
        const db = getFirestore(ANOTHER_USER);
        const testDoc = db.collection("users").doc("speedypleath");
        await firebase.assertFails(testDoc.delete());
    });

    it("Can delete user if it does correspond to authenticated user", async () => {
        const db = getFirestore(USER);
        const testDoc = db.collection("users").doc("speedypleath");
        await firebase.assertSucceeds(testDoc.delete());
    });

    after(async () => {
        const db = getFirestore(USER);
        const testDoc = db.collection("users").doc("speedypleath");
        await firebase.assertSucceeds(testDoc.set({userId: "speedypleath"}));
    });
});

describe("Events", () => {
    it("Can write to events if authenticated", async () => {
        const db = getFirestore(USER);
        const testDoc = db.collection("events").doc("testDoc");
        await firebase.assertSucceeds(testDoc.set({organiser: "speedypleath", facebookId: "123"}));
    });

    it("Can't modify event if authenticated user is not the owner of requested event", async () => {
        const db = getFirestore(ANOTHER_USER);
        const testDoc = db.collection("events").doc("testDoc");
        await firebase.assertFails(testDoc.update({ foo: "bar" }));
    });

    it("Can modify event if authenticated user is the owner of requested event", async () => {
        const db = getFirestore(USER);
        const testDoc = db.collection("events").doc("testDoc");
        await firebase.assertSucceeds(testDoc.update({ bar: "foo", facebookId: "123", organiser: "speedypleath"}));
    });

    it("Can follow event", async () => {
        const db = getFirestore(ANOTHER_USER); 
        const testDoc = db.collection("events").doc("testDoc");
        await firebase.assertSucceeds(testDoc.update({ followersCount: firebase.firestore.FieldValue.increment(1)}));
    });

    it("Can't delete event if authenticated user is not the owner of requested event", async () => {
        const db = getFirestore(ANOTHER_USER);
        const testDoc = db.collection("events").doc("testDoc");
        await firebase.assertFails(testDoc.delete());
    });

    it("Can delete event if authenticated user is the owner of requested event", async () => {
        const db = getFirestore(USER);
        const testDoc = db.collection("events").doc("testDoc");
        await firebase.assertSucceeds(testDoc.delete());
    });
});

describe("Artists", () => {
    it("Can write to artist if authenticated", async () => {
        const db = getFirestore(USER);
        const testDoc = db.collection("artists").doc("testDoc");
        await firebase.assertSucceeds(testDoc.set({userId: "speedypleath", spotifyId: "123"}));
    });

    it("Can't modify artist authenticated user id is not equal to artist's organiser", async () => {
        const db = getFirestore(ANOTHER_USER);
        const testDoc = db.collection("artists").doc("testDoc");
        await firebase.assertFails(testDoc.update({ foo: "bar" }));
    });

    it("Can modify artist if authenticated user id is not equal to artist's organiser", async () => {
        const db = getFirestore(USER);
        const testDoc = db.collection("artists").doc("testDoc");
        await firebase.assertSucceeds(testDoc.update({ bar: "foo", spotifyId: "123", organiser: "speedypleath"}));
    });

    it("Can't delete artist if authenticated user id is not equal to artist's organiser", async () => {
        const db = getFirestore(ANOTHER_USER);
        const testDoc = db.collection("artists").doc("testDoc");
        await firebase.assertFails(testDoc.delete());
    });

    it("Can delete artist if authenticated user id is equal to artist's organiser", async () => {
        const db = getFirestore(USER);
        const testDoc = db.collection("artists").doc("testDoc");
        await firebase.assertSucceeds(testDoc.delete());
    });

    after(async () => {
        const db = getFirestore(USER);
        const testDoc = db.collection("users").doc("speedypleath");
        await testDoc.delete();
    });
});
const functions = require("firebase-functions");
const FB = require("fbgraph");
const admin = require("firebase-admin");
admin.initializeApp();

// eslint-disable-next-line require-jsdoc
function syncFacebookEvents(authToken) {
  FB.setAccessToken(authToken);
  FB.get("me/events", function(err, res) {
    const data = res["data"];
    for (const key in data) {
      if ({}.hasOwnProperty.call(data, key)) {
        console.log(data[key]["id"]);
        const fetch = new Promise((resolve, reject) => {
          FB.get(data[key]["id"]+"?fields=cover,is_online",
              (err2, res2) => {
                resolve((res2["cover"]["source"], res2["is_online"]));
              });
        });
        fetch.then((cover, isOnline) => {
          admin.firestore().collection("events")
              .where("facebookId", "==", data[key]["id"])
              .get().then((val) => {
                if (val.empty) {
                  admin.firestore().collection("events").add({
                    "facebookId": data[key]["id"],
                    "name": data[key]["name"],
                    "description": data[key]["description"],
                    "image": cover,
                    "location": data[key]["place"]["name"],
                    "isOnline": isOnline,
                  });
                }
              }
              ).catch((err) => console.log(err));
        });
      }
    }
  });
}

admin.firestore().settings({ignoreUndefinedProperties: true});


exports.syncFacebookEventsInstant = functions.https.onCall( (data, context) => {
  syncFacebookEvents(data.authToken);
});

exports.syncFacebookEventsPeridodic = functions.pubsub.schedule("0 14 * * *")
    .timeZone("Europe/Bucharest")
    .onRun(() => {
      admin.firestore().collection("users").get().then((query) => {
        query.docs.forEach((user) => {
          syncFacebookEvents(user.data().authToken);
        });
      });
    });

exports.importFacebookEvents = functions.https.onCall( (data, context) => {
  FB.setAccessToken(data.authToken);
  FB.get("me/events", function(err, res) {
    const data = res["data"];
    for (const key in data) {
      if ({}.hasOwnProperty.call(data, key)) {
        console.log(data[key]["id"]);
        const fetch = new Promise((resolve, reject) => {
          FB.get(data[key]["id"]+"?fields=cover",
              (err2, res2) => {
                resolve((res2["cover"]["source"], res2["is_online"]));
              });
        });
        fetch.then((cover, isOnline) => {
          admin.firestore().collection("events")
              .where("facebookId", "==", data[key]["id"])
              .get().then((val) => {
                if (val.empty) {
                  admin.firestore().collection("events").add({
                    "facebookId": data[key]["id"],
                    "name": data[key]["name"],
                    "description": data[key]["description"],
                    "image": cover,
                    "isOnline": isOnline,
                    "location": data[key]["place"]["name"],
                  });
                  console.log(isOnline);
                }
              }
              ).catch((err) => console.log(err));
        });
      }
    }
    return null;
  });
});

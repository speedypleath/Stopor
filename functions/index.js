const functions = require("firebase-functions");
const FB = require("fbgraph");
const admin = require("firebase-admin");
admin.initializeApp();

exports.syncFacebookEvents = functions.pubsub.schedule("5 11 * * *")
    .onRun(() => {
      admin.firestore().collection("users").get().then((query) => {
        query.docs.forEach((user) => {
          FB.setAccessToken(user.data().authToken);
          FB.get("me/events", function(err, res) {
            const data = res["data"];
            for (const key in data) {
              if ({}.hasOwnProperty.call(data, key)) {
                console.log(data[key]["id"]);
                const fetch = new Promise((resolve, reject) => {
                  FB.get(data[key]["id"]+"?fields=cover",
                      (err2, res2) => {
                        resolve(res2["cover"]["source"]);
                      });
                });
                fetch.then((cover) => {
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
                          });
                        }
                      }
                      ).catch((err) => console.log(err));
                });
              }
            }
          });
        });
      });
    });

exports.importFacebookEvents = functions.https.onCall( (data, context) => {
  const facebookToken = data.facebookToken;
  console.log("da " + facebookToken);
  FB.setAccessToken(facebookToken);
  FB.get("me/events", function(err, res) {
    const data = res["data"];
    for (const key in data) {
      if ({}.hasOwnProperty.call(data, key)) {
        console.log(data[key]["id"]);
        const fetch = new Promise((resolve, reject) => {
          FB.get(data[key]["id"]+"?fields=cover",
              (err2, res2) => {
                resolve(res2["cover"]["source"]);
              });
        });
        fetch.then((cover) => {
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
                  });
                }
              }
              ).catch((err) => console.log(err));
        });
      }
    }
    return {
      "message": "Hello, world",
    };
  });
});

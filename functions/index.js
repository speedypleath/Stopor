/* eslint-disable require-jsdoc */
const functions = require("firebase-functions");
const FB = require("fbgraph");
const admin = require("firebase-admin");
const fetch = require("node-fetch");
admin.initializeApp();

function fetchUntilCondition(url, method, header) {
  fetch(url, {
    method: method,
    headers: header,
  }).then((res) => res.json())
      .then((response) => {
        const artists = response["artists"]["items"];
        for (const x in artists) {
          if ({}.hasOwnProperty.call(artists, x)) {
            const artist = artists[x];
            console.log(artist);
            admin.firestore().collection("artists")
                .where("spotifyId", "==", artist["id"])
                .get().then((val) => {
                  if (val.empty) {
                    admin.firestore().collection("artists").add({
                      "spotifyId": artist["id"],
                      "name": artist["name"],
                      "genres": artist["genres"],
                      "image": artist["images"][1]["url"],
                    });
                  } else {
                    val.docs[0].ref.update({
                      "spotifyId": artist["id"],
                      "name": artist["name"],
                      "genres": artist["genres"],
                      "image": artist["images"][1]["url"],
                    });
                  }
                }
                ).catch((err) => console.log(err));
          }
        }
        console.log(response["artists"]["next"]);
        if (response["artists"]["next"] != null) {
          console.log("da");
          const newUrl = response["artists"]["next"];
          console.log(newUrl);
          fetchUntilCondition(newUrl, method, header);
        }
      });
}

function importSpotifyArtists(authToken) {
  const url = "https://api.spotify.com/v1/me/following?type=artist&limit=50";
  const method = "GET";
  const header = {
    "Content-Type": "application/json",
    "Authorization": `Bearer ${authToken}`,
  };
  fetchUntilCondition(url, method, header);
}

function importFacebookEvents(authToken) {
  FB.setAccessToken(authToken);
  FB.get("me/events", function(err, res) {
    const data = res["data"];
    for (const key in data) {
      if ({}.hasOwnProperty.call(data, key)) {
        const fetch = new Promise((resolve, reject) => {
          FB.get(data[key]["id"]+"?fields=cover,is_online",
              (err2, res2) => {
                console.log(res2["is_online"]);
                resolve({cover: res2["cover"]["source"],
                  isOnline: res2["is_online"]});
              });
        });
        fetch.then((fields) => {
          admin.firestore().collection("events")
              .where("facebookId", "==", data[key]["id"])
              .get().then((val) => {
                if (val.empty) {
                  admin.firestore().collection("events").add({
                    "facebookId": data[key]["id"],
                    "name": data[key]["name"],
                    "description": data[key]["description"],
                    "image": fields["cover"],
                    "isOnline": fields["isOnline"],
                    "location": data[key]["place"]["name"],
                  });
                } else {
                  val.docs[0].ref.update({
                    "name": data[key]["name"],
                    "description": data[key]["description"],
                    "image": fields["cover"],
                    "isOnline": fields["isOnline"],
                    "location": data[key]["place"]["name"],
                  });
                }
              }
              ).catch((err) => console.log(err));
        });
      }
    }
    return null;
  });
}

admin.firestore().settings({ignoreUndefinedProperties: true});

exports.syncFacebookEventsPeridodic = functions.pubsub.schedule("0 14 * * *")
    .timeZone("Europe/Bucharest")
    .onRun(() => {
      admin.firestore().collection("users").get().then((query) => {
        query.docs.forEach((user) => {
          importFacebookEvents(user.data().authToken);
        });
      });
    });

exports.importFacebookEventsInstant = functions.https.onCall(
    (data, context) => {
      importFacebookEvents(data.authToken);
    });

exports.importSpotifyArtistsInstant = functions.https.onCall(
    (data, context) => {
      importSpotifyArtists(data.authToken);
    });

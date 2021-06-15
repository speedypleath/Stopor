/* eslint-disable require-jsdoc */
const functions = require("firebase-functions");
const FB = require("fbgraph");
const admin = require("firebase-admin");
const fetch = require("node-fetch");
admin.initializeApp();
const geo = require("geofirex").init(admin);
var msgData;
exports.offerTrigger = functions.firestore.document
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
            admin.firestore().collection("artists")
                .where("spotifyId", "==", artist["id"])
                .get().then((val) => {
                  const genresMap = {};
                  console.log(genresMap);
                  for (const genre in artist["genres"]) {
                    if ({}.hasOwnProperty.call(artist["genres"], genre)) {
                      genresMap[artist["genres"][genre]] = true;
                    }
                  }
                  console.log(genresMap);
                  if (val.empty) {
                    admin.firestore().collection("artists").add({
                      "spotifyId": artist["id"],
                      "name": artist["name"],
                      "genres": genresMap,
                      "image": artist["images"][1]["url"],
                      "documentType": "artist",
                    });
                  } else {
                    val.docs[0].ref.update({
                      "spotifyId": artist["id"],
                      "name": artist["name"],
                      "genres": genresMap,
                      "image": artist["images"][1]["url"],
                      "documentType": "artist",
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
  return FB.get("me/events", function(err, res) {
    const data = res["data"];
    for (const key in data) {
      if ({}.hasOwnProperty.call(data, key)) {
        const fetch = new Promise((resolve, reject) => {
          FB.get(data[key]["id"]+"?fields=cover,is_online",
              (err2, res2) => {
                resolve({cover: res2["cover"] !=
                  null ? res2["cover"]["source"] : null,
                isOnline: res2["is_online"]});
              });
        });
        return fetch.then((fields) => {
          admin.firestore().collection("events")
              .where("facebookId", "==", data[key]["id"])
              .get().then((val) => {
                let location = null;
                if (data[key]["place"] != null) {
                  if (data[key]["place"]["location"] != null) {
                    const position = geo.point(
                        parseFloat(data[key]["place"]["location"]["latitude"]),
                        parseFloat(data[key]["place"]["location"]["longitude"]
                        ));
                    location = {name: data[key]["place"]["name"], position};
                  }
                }
                console.log(data[key]["start_time"]);
                if (val.empty) {
                  admin.firestore().collection("events").add({
                    "facebookId": data[key]["id"],
                    "name": data[key]["name"],
                    "description": data[key]["description"],
                    "image": fields["cover"],
                    "isOnline": fields["isOnline"],
                    "location": location,
                    "date": admin.firestore.Timestamp
                        .fromDate(new Date(data[key]["start_time"])),
                    "followersCount": 0,
                    "documentType": "event",
                  });
                } else {
                  val.docs[0].ref.update({
                    "name": data[key]["name"],
                    "description": data[key]["description"],
                    "image": fields["cover"],
                    "isOnline": fields["isOnline"],
                    "date": admin.firestore.Timestamp
                        .fromDate(new Date(data[key]["start_time"])),
                    "location": location,
                    "documentType": "event",
                  });
                }
              }
              ).catch((err) => {
                console.log(err);
                return err;
              }).finally(() => "succes");
        });
      }
    }
  });
}

admin.firestore().settings({ignoreUndefinedProperties: true});

exports.syncFacebookEventsPeridodic = functions.pubsub.schedule("0 14 * * *")
    .timeZone("Europe/Bucharest")
    .onRun(() => {
      admin.firestore().collection("users").get().then((query) => {
        query.docs.forEach((user) => {
          importFacebookEvents(user.data()["authToken"]);
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

exports.setDocumentId = functions.firestore
    .document("events/{docId}")
    .onCreate((snap, context) => {
      return snap.ref.update({"documentId": context.params.docId});
    });

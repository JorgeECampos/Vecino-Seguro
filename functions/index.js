// functions/index.js
const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// Function HTTP: getReportes
exports.getReportes = functions.https.onRequest(async (req, res) => {
  try {
    const snapshot = await admin
        .firestore()
        .collection("reportes")
        .orderBy("fecha", "desc")
        .get();

    const data = snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));

    res.json(data);
  } catch (error) {
    console.error("Error al recuperar reportes:", error);
    res.status(500).send("Error al obtener reportes");
  }
});

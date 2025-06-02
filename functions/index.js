// functions/index.js
const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Inicializar Admin SDK
admin.initializeApp();

// Función HTTP: getReportes
exports.getReportes = functions.https.onRequest(async (req, res) => {
  try {
    // Recuperar todos los reportes, ordenados por fecha descendente
    const snapshot = await admin
        .firestore()
        .collection("reportes")
        .orderBy("fecha", "desc")
        .get();

    // Mapear cada doc a un objeto con id + datos
    const data = snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));

    // Enviar JSON con todos los reportes
    res.json(data);
  } catch (error) {
    console.error("Error al recuperar reportes:", error);
    res.status(500).send("Error al obtener reportes");
  }
});

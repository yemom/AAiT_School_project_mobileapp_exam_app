// functions/index.js
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

function assertAuth(context) {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "You must be signed in to call this function."
    );
  }
}

exports.promoteToAdmin = functions.https.onCall(async (data, context) => {
  assertAuth(context);
  const claims = context.auth.token || {};
  if (claims.superAdmin !== true) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Super-admin only"
    );
  }

  const targetUid = data && data.uid;
  if (!targetUid) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Please provide a target UID."
    );
  }

  // Merge with existing claims to avoid dropping others (e.g., approved)
  const user = await admin.auth().getUser(targetUid);
  const existing = user.customClaims || {};
  await admin.auth().setCustomUserClaims(targetUid, { ...existing, admin: true });
  await admin.firestore().doc(`users/${targetUid}`).set({ role: "Admin" }, { merge: true });

  return { message: `User ${targetUid} promoted to admin` };
});

exports.promoteToSuperAdmin = functions.https.onCall(async (data, context) => {
  assertAuth(context);
  const claims = context.auth.token || {};
  if (claims.superAdmin !== true) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Only super admins can promote other users to super admin."
    );
  }

  const targetUid = data && data.uid;
  if (!targetUid) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Please provide a target UID."
    );
  }

  const user = await admin.auth().getUser(targetUid);
  const existing = user.customClaims || {};
  await admin.auth().setCustomUserClaims(targetUid, { ...existing, superAdmin: true, admin: true });
  await admin.firestore().doc(`users/${targetUid}`).set({ role: "SuperAdmin" }, { merge: true });

  return { message: `User ${targetUid} promoted to Super Admin!` };
});

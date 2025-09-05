const admin = require('firebase-admin');
admin.initializeApp();

(async () => {
  const uid = process.argv[2];
  if (!uid) {
    console.error('Usage: node scripts/make-super-admin.js <UID>');
    process.exit(1);
  }
  const user = await admin.auth().getUser(uid);
  const claims = user.customClaims || {};
  await admin.auth().setCustomUserClaims(uid, { ...claims, superAdmin: true });
  console.log(`Super admin set for ${uid}`);
  process.exit(0);
})().catch(err => {
  console.error(err);
  process.exit(1);
});


const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {onCall, HttpsError} = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

exports.sendNotificationOnCreate = onDocumentCreated(
  "users/{uid}/notifications/{notificationId}",
  async (event) => {
    const notification = event.data && event.data.data();
    if (!notification || notification.source === "fcm") return;

    const uid = event.params.uid;
    const tokenSnapshot = await db
      .collection("users")
      .doc(uid)
      .collection("fcmTokens")
      .get();

    const tokens = tokenSnapshot.docs
      .map((doc) => doc.data().token)
      .filter(Boolean);

    if (tokens.length === 0) return;

    const data = Object.fromEntries(
      Object.entries(notification.data || {}).map(([key, value]) => [
        key,
        String(value),
      ]),
    );

    await messaging.sendEachForMulticast({
      tokens,
      notification: {
        title: notification.title || "ExamAce",
        body: notification.body || "",
      },
      data: {
        ...data,
        type: notification.type || "general",
        route: notification.route || "/notifications",
        notificationId: event.params.notificationId,
      },
      android: {
        priority: "high",
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
          },
        },
      },
    });
  },
);

exports.createNotification = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign in required.");
  }

  const {uid, title, body, type, route, data} = request.data || {};
  if (!uid || !title) {
    throw new HttpsError("invalid-argument", "uid and title are required.");
  }

  if (request.auth.uid !== uid && request.auth.token.admin !== true) {
    throw new HttpsError(
      "permission-denied",
      "You can only create notifications for your own account.",
    );
  }

  await db.collection("users").doc(uid).collection("notifications").add({
    title,
    body: body || "",
    type: type || "general",
    route: route || "/notifications",
    data: data || {},
    isRead: false,
    archived: false,
    source: "function",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return {ok: true};
});

# EventSphere

EventSphere is a Flutter event board backed by a Spring Boot REST API. Users can create events, apply with their name and reason, and view the applicants. The backend stores data in a local H2 database file under `backend/data/`.

## Requirements

- Flutter SDK with Dart 3.5 or later
- Java 17 or later
- Gradle 8.14 or later

## Run the backend

From the project root:

```powershell
Set-Location .\backend
gradle bootRun
```

The API listens on `http://localhost:8080`. Verify it with:

```powershell
Invoke-RestMethod http://localhost:8080/api/health
Invoke-RestMethod http://localhost:8080/api/events
```

Run backend tests from `backend/` with `gradle test`.

## Run the Flutter app

From the project root, add the Android runner once if it does not exist:

```powershell
Set-Location .\frontend
flutter create --platforms=android .
flutter pub get
```

For local HTTP development, edit `android/app/src/main/AndroidManifest.xml` and add `android:usesCleartextTraffic="true"` to the `<application>` element. This is only for local development; production should use HTTPS. Start an Android emulator, then run:

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

The `10.0.2.2` address lets the Android emulator reach the backend on the host computer. For web, use `flutter run -d chrome` with the default `http://localhost:8080` API URL. For a physical device, pass the development machine's LAN address instead. Run Flutter tests with `flutter test` from `frontend/`.

## Event API

All endpoints are currently unauthenticated and intended for local development.

| Method | Path | Purpose |
| --- | --- | --- |
| `GET` | `/api/health` | Check backend status |
| `GET` | `/api/events` | List events and application counts |
| `POST` | `/api/events` | Create an event |
| `POST` | `/api/events/{eventId}/applications` | Apply to an event |
| `GET` | `/api/events/{eventId}/applications` | List applicants and reasons |

Create-event body:

```json
{
	"name": "Campus Build Day",
	"duration": "1 day",
	"description": "A day to build something useful."
}
```

Application body:

```json
{
	"applicantName": "Taylor Morgan",
	"reason": "I enjoy building tools."
}
```

The backend validates required fields and lengths. It rejects a second application with the same name for an event with HTTP `409`. H2 database files are ignored by Git.

## Limitations

This is the requested event/application slice, not the full EventSphere specification. Firebase Authentication, identity-based duplicate prevention, admin roles, event editing/cancellation, and production database configuration are not implemented. Applicant names are user-entered and are not authenticated identities; do not deploy this API publicly until authentication and authorization are added.
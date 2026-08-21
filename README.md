# EMN Plant workforce app

Flutter workforce application backed by PocketBase at
`https://emnapi.dylanwiseman.com`.

## Current functionality

- PocketBase authentication with persisted sessions
- Employee and manager roles
- Worker account management
- Job management and worker assignment
- Diary-style scheduled job view
- Manual timesheets using date, start time, end time and break duration
- Manager timesheet approval and rejection

Worked hours are calculated as `(end time - start time) - break`. The app has
no running timers, wage calculations, billing rates or billable-hour tracking.

## PocketBase migrations

Migrations are in `server/pb_migrations/` and must be applied in timestamp
order. Existing production collections must not be recreated.

The current follow-up migrations are:

- `1787301000_simplify_user_fields.js`
- `1787302000_add_timesheet_shift_times.js`

Back up `pb_data` before applying migrations.

## Validation

```bash
flutter pub get
flutter analyze
flutter test
```

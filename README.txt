EMN Plant - PocketBase database integration files

Desired users collection
------------------------
Built-in PocketBase auth fields:
- email
- emailVisibility
- verified
- password (managed by PocketBase; never displayed)

Custom fields:
- name
- role        (employee / manager)
- active
- job_title

Jobs and timesheets remain unchanged.

FILES TO COPY INTO YOUR FLUTTER PROJECT
---------------------------------------
lib/models/workflow_models.dart
lib/services/pocketbase_service.dart
lib/providers/business_provider.dart
lib/screens/game_shell_screen.dart

SERVER MIGRATIONS
-----------------
server/pb_migrations/1787300000_emn_workforce.js
  Clean-install schema. Keep this in source control.

server/pb_migrations/1787301000_simplify_user_fields.js
  THIS is the migration your CURRENT server needs because 1787300000 has
  already been applied.

CURRENT SERVER INSTALL
----------------------
1. Upload 1787301000_simplify_user_fields.js to:
   /opt/pocketbase/pb_migrations/

2. Run:
   cd /opt/pocketbase
   sudo chown www-data:www-data pb_migrations/1787301000_simplify_user_fields.js
   sudo -u www-data ./pocketbase migrate up
   sudo systemctl restart pocketbase

3. Verify:
   curl -sS https://emnapi.dylanwiseman.com/api/health

4. In PocketBase admin, Users should contain custom fields:
   name, role, active, job_title
   plus PocketBase's built-in auth fields email, emailVisibility, verified.

NOTES
-----
- emailVisibility is set false when the Flutter app creates a worker.
- verified is left as PocketBase's built-in field; the app does not depend on it.
- active controls whether the user can authenticate.
- Managers can set/reset passwords, but passwords are never readable/stored in Flutter.

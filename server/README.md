# EMN Plant PocketBase backend

The Flutter app is configured to use:

`https://emnapi.dylanwiseman.com`

## Install the schema on the server

Copy the migration from this project to the PocketBase server:

```bash
sudo mkdir -p /opt/pocketbase/pb_migrations
sudo cp 1787300000_emn_workforce.js /opt/pocketbase/pb_migrations/
sudo chown www-data:www-data /opt/pocketbase/pb_migrations/1787300000_emn_workforce.js
cd /opt/pocketbase
sudo -u www-data ./pocketbase migrate up
```

If PocketBase is running as a systemd service, restart it after a manual migration:

```bash
sudo systemctl restart pocketbase
sudo systemctl status pocketbase --no-pager
```

Verify:

```bash
curl -sS https://emnapi.dylanwiseman.com/api/health
```

## Create the first app manager

Sign in to the PocketBase dashboard at `https://emnapi.dylanwiseman.com/_/` using the PocketBase superuser account.

Open the `users` collection and create a record with:

- email: the manager's login email
- password / passwordConfirm: a strong password
- name: manager name
- role: `manager`
- active: enabled
- job_title: e.g. `Site Manager`

Do not put the PocketBase superuser account or password in the Flutter app.

## App permissions

Employees can sign in, read jobs, create their own pending timesheets, and see their own timesheets.
Managers can additionally manage jobs, view/approve team timesheets, and manage worker auth records (including setting/resetting passwords).

Managers cannot read existing worker passwords. Password reset writes a new password through PocketBase's managed auth API.

Workers with historical timesheets should normally be disabled rather than deleted. The Flutter app prevents deleting a worker when loaded timesheet history exists.

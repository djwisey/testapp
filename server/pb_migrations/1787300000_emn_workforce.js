/// PocketBase migration for the EMN Plant workforce app.
/// Copy this file to /opt/pocketbase/pb_migrations/ and run:
///   cd /opt/pocketbase && ./pocketbase migrate up
migrate((app) => {
  const users = new Collection({
    type: "auth",
    name: "users",
    listRule: '@request.auth.id != "" && @request.auth.active = true && (@request.auth.role = "manager" || id = @request.auth.id)',
    viewRule: '@request.auth.id != "" && @request.auth.active = true && (@request.auth.role = "manager" || id = @request.auth.id)',
    createRule: '@request.auth.active = true && @request.auth.role = "manager" && @request.body.role = "employee"',
    updateRule: '@request.auth.active = true && @request.auth.role = "manager"',
    deleteRule: '@request.auth.active = true && @request.auth.role = "manager" && id != @request.auth.id',
    manageRule: '@request.auth.role = "manager" && @request.auth.active = true',
    authRule: 'active = true',
    fields: [
      { type: "text", name: "name", required: true, max: 120 },
      { type: "select", name: "role", required: true, maxSelect: 1, values: ["employee", "manager"] },
      { type: "bool", name: "active" },
      { type: "text", name: "job_title", max: 120 },
    ],
    passwordAuth: { enabled: true, identityFields: ["email"] },
    indexes: [],
  });
  app.save(users);

  const jobs = new Collection({
    type: "base",
    name: "jobs",
    listRule: '@request.auth.id != "" && @request.auth.active = true',
    viewRule: '@request.auth.id != "" && @request.auth.active = true',
    createRule: '@request.auth.active = true && @request.auth.role = "manager"',
    updateRule: '@request.auth.active = true && @request.auth.role = "manager"',
    deleteRule: '@request.auth.active = true && @request.auth.role = "manager"',
    fields: [
      { type: "text", name: "reference", required: true, max: 60 },
      { type: "text", name: "title", required: true, max: 180 },
      { type: "text", name: "description", max: 3000 },
      { type: "text", name: "site_address", max: 300 },
      { type: "select", name: "status", required: true, maxSelect: 1, values: ["New", "Scheduled", "In Progress", "On Hold", "Completed", "Cancelled"] },
      { type: "date", name: "scheduled_date" },
      { type: "text", name: "notes", max: 5000 },
      { type: "bool", name: "active" },
      { type: "relation", name: "assigned_employees", collectionId: users.id, maxSelect: 100 },
      { type: "relation", name: "created_by", collectionId: users.id, maxSelect: 1 },
    ],
    indexes: ["CREATE UNIQUE INDEX idx_jobs_reference ON jobs (reference)"],
  });
  app.save(jobs);

  const timesheets = new Collection({
    type: "base",
    name: "timesheets",
    listRule: '@request.auth.id != "" && @request.auth.active = true && (@request.auth.role = "manager" || employee = @request.auth.id)',
    viewRule: '@request.auth.id != "" && @request.auth.active = true && (@request.auth.role = "manager" || employee = @request.auth.id)',
    createRule: '@request.auth.id != "" && @request.auth.active = true && employee = @request.auth.id && approval_status = "pending"',
    updateRule: '(@request.auth.active = true && @request.auth.role = "manager") || (@request.auth.active = true && employee = @request.auth.id && approval_status = "pending" && @request.body.employee:changed = false && @request.body.approval_status:changed = false)',
    deleteRule: '(@request.auth.active = true && @request.auth.role = "manager") || (@request.auth.active = true && employee = @request.auth.id && approval_status = "pending")',
    fields: [
      { type: "relation", name: "employee", required: true, collectionId: users.id, maxSelect: 1 },
      { type: "relation", name: "job", collectionId: jobs.id, maxSelect: 1 },
      { type: "text", name: "other_job", max: 240 },
      { type: "date", name: "date", required: true },
      { type: "number", name: "hours", required: true, min: 0.01, max: 24 },
      { type: "text", name: "notes", max: 4000 },
      { type: "select", name: "approval_status", required: true, maxSelect: 1, values: ["pending", "approved", "rejected"] },
      { type: "relation", name: "approved_by", collectionId: users.id, maxSelect: 1 },
      { type: "date", name: "approved_at" },
    ],
  });
  app.save(timesheets);
}, (app) => {
  for (const name of ["timesheets", "jobs", "users"]) {
    try { app.delete(app.findCollectionByNameOrId(name)); } catch (_) {}
  }
});

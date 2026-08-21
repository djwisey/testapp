/// Updates the existing EMN Plant `users` auth collection.
/// Keeps PocketBase built-in auth fields: email, emailVisibility, verified.
/// Custom user fields after this migration: name, role, active, job_title.
migrate((app) => {
  const users = app.findCollectionByNameOrId("users");

  // Remove the old employee number index before removing its field.
  users.removeIndex("idx_users_employee_number");
  users.fields.removeByName("employee_number");
  users.fields.removeByName("department");

  // FieldsList.add replaces by name when present, otherwise appends.
  users.fields.add(new TextField({
    name: "job_title",
    max: 120,
  }));

  app.save(users);
}, (app) => {
  const users = app.findCollectionByNameOrId("users");

  users.fields.removeByName("job_title");
  users.fields.add(new TextField({ name: "employee_number", max: 40 }));
  users.fields.add(new TextField({ name: "department", max: 120 }));
  users.addIndex(
    "idx_users_employee_number",
    true,
    "employee_number",
    "employee_number != ''"
  );

  app.save(users);
});

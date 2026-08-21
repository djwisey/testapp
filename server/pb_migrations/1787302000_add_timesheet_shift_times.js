/// Adds retrospective shift timing fields without changing existing records.
migrate((app) => {
  const timesheets = app.findCollectionByNameOrId("timesheets");

  timesheets.fields.add(new DateField({ name: "start_time" }));
  timesheets.fields.add(new DateField({ name: "end_time" }));
  timesheets.fields.add(new NumberField({
    name: "break_hours",
    min: 0,
    max: 24,
  }));

  app.save(timesheets);
}, (app) => {
  const timesheets = app.findCollectionByNameOrId("timesheets");
  timesheets.fields.removeByName("start_time");
  timesheets.fields.removeByName("end_time");
  timesheets.fields.removeByName("break_hours");
  app.save(timesheets);
});

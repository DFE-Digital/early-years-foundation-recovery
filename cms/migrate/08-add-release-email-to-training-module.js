module.exports = function (migration) {
  const trainingModule = migration.editContentType("trainingModule");

  trainingModule.createField("sendReleaseEmail", {
    name: "Send module release email",
    type: "Boolean",
    required: false,
    defaultValue: {
      "en-US": false,
    },
  });

  trainingModule.changeFieldControl("sendReleaseEmail", "builtin", "boolean", {
    helpText:
      "Send an email announcement when this module is released. Each module can only be announced once. Leaving this enabled or switching it off and on will not resend the announcement.",
  });
};

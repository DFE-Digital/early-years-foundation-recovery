# Deployment and Content Recovery

Rolling back a failed code release and restoring a database has been tested and there
is a strategy in place to provide the same assurances with content.

However there are a number of improvements that could still be made:


### Recommendations

1.
  Ensure content restoration is possible whenever a coordinated code/content release is actioned.

  - Contentful does not provide the functionality, `Launch` to can only be used to publish.
  - If multiple entries need to be reverted or unpublished then a pre-launch clone
    of the environment must be made.
  - This places a restriction on teams of content editors to pause work until the
    success of the combined code and content release can be verified.
  - There are a limited number of environments in the current plan so only one restore point of the master can
  exist.

2.
  The web server Azure AppService and background worker Azure Container share a
  database however migrations are only run within the AppService after a blue/green swap.

  - The worker will be recreated with new code before the web server can run any migrations it may require.
  - The deployment may interrupt active jobs.
    Split deployment of web app and background worker up

3.
  Increase fast restore points in Azure to more than once in 24hrs (cost may be incurred)



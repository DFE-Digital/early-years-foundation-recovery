## Dashboard export

[Dashboard Live](https://pages.github.com/)

There 4 tables in the application we are using Rake task's to export the data on to Google Cloud Storage (GCP) 

**Tables:**
```
users, ahoy_events, user_assessments, ahoy_visits
```

**Rake tasks:**

users table:
```
rake db:analytics:users
```
ahoy_events table:
```
rake db:ahoy_events:users
```
user_assessments table:
```
rake db:user_assessments:users
```
user_answers table:
```
rake db:user_answers:users
```
ahoy_visits table:
```
rake db:ahoy_visits:users
```


**How to add a new rake task**

Add a new task in *lib/tasks/analytics.rake* create a new sql for the new table note we are using some advance sql to pull data out of the jsonb fields in the database.

# Data Dashboard Export

Data dashboard gives a visual interpretation of the events within this application, it is built within [Data Studio Google](https://datastudio.google.com/) and the corresponding data is stored within [Google Cloud Storage](https://cloud.google.com/) as CSV files which are uploaded via Rake tasks.



## Links

[Rake tasks](#rake-tasks)

[Build csv files on local machine](#build-csv-files-on-local-machine)


## Overview

Currently there are 4 tables in the application we are using Rake task's to export the data on to Google Cloud Storage (GCP) 
**Tables:**, *users, ahoy_events, user_assessments, ahoy_visits*


## Rake tasks:

users table:
```ruby
rake db:analytics:users
```

ahoy_events table:

```ruby
rake db:analytics:ahoy_events
```

user_assessments table:

```ruby
rake db:analytics:user_assessments
```

user_answers table:

```ruby
rake db:analytics:user_answers
```

ahoy_visits table:

```ruby
rake db:analytics:ahoy_visits
```

## Build csv files on local machine

Start by creating a folder in the root of the project called **analytics_files** and then 
do the following for all the rake tasks, ie, ahoy_visits rake task comment out the below code

```ruby
# ahoy_visit.create! if Rails.env.test?
# ahoy_visit.delete_files if Rails.env.production? || Rails.env.development?
# ahoy_visit.upload if Rails.env.production? || Rails.env.development?
```

and uncomment the code below

```ruby
ahoy_visit.create!
```

and then run code below this should populate analytics_files with csv file / files.

```ruby
rake db:analytics:ahoy_visits
```

# Data Dashboard Export

Data dashboard gives a visual interpretation of the events within this application.
It is built within [Looker Studio Google](https://datastudio.google.com/) and the
corresponding data is stored within [Google Cloud Storage](https://cloud.google.com/)
as CSV files which are uploaded via Rake tasks.

These tasks should be reviewed when structural changes to the database or dataset
are made as the data dashboard is reliant on the structure it receives from the csv 
files. If this structure is not followed then the dashboard will break.
## Table of contents

- [Overview](#overview)
- [Rake tasks](#rake-tasks)
- [Build CSV files on local machine](#build-csv-files-on-local-machine)
- [Add a new task](#add-a-new-rake-task)
## Overview

Currently there are 5 tables in the application whose data we are exporting to 
Google Cloud Storage using Rake tasks:

**Tables:** *users, ahoy_events, user_assessments, user_answers, ahoy_visits*


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

1. Create a folder called 'analytics_files' in the root of the directory.

2. Within each task in the `analytics.rake` file, comment out the equivalent 
three lines. In the ahoy_visit task, they look like this:
```ruby
ahoy_visit.create! if Rails.env.test?
ahoy_visit.delete_files if Rails.env.production? || Rails.env.development?
ahoy_visit.upload if Rails.env.production? || Rails.env.development?
```

3. Uncomment the line below, which looks like this in the ahoy_visit task:
```ruby
ahoy_visit.create!
```

4. Run the above [Rake tasks](#rake-tasks). In this example, it would be:
```ruby
rake db:analytics:ahoy_visits
```

## Add a new rake task:

Open **lib/tasks/analytics.rake** 

Copy the code below and paste it just above the last **end** statement within 
**lib/tasks/analytics.rake**

```ruby
    desc 'user_assessments table'
    task user_assessments: :environment do
      user_assessments = UserAssessment.all
      build_csv = AnalyticsBuild.new(bucket_name: 'GCP_Storage_bucket_name',
                                     folder_path: 'folder_path_on_GCP_Storage_bucket', 
                                     result_set: table_var, 
                                     file_name: 'name_of_the_new_files')
      build_csv.create if Rails.env.development?
      build_csv.delete_files if Rails.env.production?
      build_csv.upload if Rails.env.production?

    end
```

Description of the new task

```ruby
desc 'Add table name and some description if necessary'
```

Task command, recommended approach might be to add table name in the tasks

```ruby
task table_name: :environment do
end
```

For the actual task we first need to pull all the data from the table. Create a
new sql for the new table 

*NOTE:* we are using sql to pull data out json object from within a jsonb field
in the database if table has one.

```ruby
sql = "SELECT id, name_of_jsonb_column as json_column, (SELECT COUNT(*) FROM jsonb_object_keys(name_of_jsonb_column)) nbr_keys FROM public.table_name order by nbr_keys desc limit 1"
```

```ruby
table_var = Table.all
```

```ruby
build_csv = AnalyticsBuild.new(bucket_name: 'GCP_Storage_bucket_name',
                               folder_path: 'folder_path_on_GCP_Storage_bucket',
                               result_set: table_var,
                               file_name: 'name_of_the_new_files')
```

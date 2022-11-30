# Data Dashboard Export

Data dashboard gives a visual interpretation of the events within this application, it is built within [Data Studio Google](https://datastudio.google.com/) and the corresponding data is stored within [Google Cloud Storage](https://cloud.google.com/) as CSV files which are uploaded via Rake tasks.



## Links

[Rake tasks](#rake-tasks)

[Create a new task](#add-a-new-rake-task)


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



## Add a new rake task:

Open **lib/tasks/analytics.rake** 

Copy and paste the code bellow just above the last **end** statement within **lib/tasks/analytics.rake**

```ruby
    desc 'user_assessments table'
    task user_assessments: :environment do
      user_assessments = UserAssessment.all
      build_csv = AnalyticsBuild.new(bucket_name: 'GCP_Storage_bucket_name', folder_path: 'folder_path_on_GCP_Storage_bucket', result_set: table_var, file_name: 'name_of_the_new_files')
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

For the actual task we first need to pull all the data from the table. Create a new sql for the new table 

*NOTE:* we are using sql to pull data out json object from within a jsonb field in the database if table has one.

```ruby
sql = "SELECT id, name_of_jsonb_column as json_column, (SELECT COUNT(*) FROM jsonb_object_keys(name_of_jsonb_column)) nbr_keys FROM public.table_name order by nbr_keys desc limit 1"
```


```ruby
table_var = Table.all
```

```ruby
build_csv = AnalyticsBuild.new(bucket_name: 'GCP_Storage_bucket_name', folder_path: 'folder_path_on_GCP_Storage_bucket', result_set: table_var, file_name: 'name_of_the_new_files')
```



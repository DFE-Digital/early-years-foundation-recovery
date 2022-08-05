# Key Performance Indicators

## Getting started

The [Ahoy](https://github.com/ankane/ahoy) gem records user transactions with MVC controllers in two tables.

> `Ahoy::Tracker.new(controller: self)`

## Data overview

### Events

Example event data from the `ahoy_events` table.

| Column     | Data                        | Type        |
| ---        | ---                         | ---         |
| id         | `95`                        | Primary Key |
| visit_id   | `7`                         | Foreign Key |
| user_id    | `1`                         | Foreign Key |
| name       | `event_key`                 | String      |
| properties | `{"extensible": "data"}`    | JSON        |
| time       | `2022-06-10 07:58:09.15539` | Timestamp   |


#### Event Dictionary

Event `name`s are:

- unique to the controller
- provide context
- in the present tense

Event `properties` are:

- include `request.path_parameters` by default
- include `/path/to/page` by default
- stateless so don't need to be aware of previous events
- require `success` as a boolean where appropriate

**Example:**

Profile management in the format `{user_attribute}_change`

- successful profile name change: `user_name_change`, `{ success: false }`
- successful profile password change: `user_password_change`, `{ success: true }`
- unsuccessful profile password change: `user_password_change`, `{ success: false }`

**NB: currently tracks the attempt and not what data has changed**

### Visits

Example event data from the `ahoy_visits` table.

| Column           | Data                                                                                                                        |
| ---              | ---                                                                                                                         |
| id               | `3`                                                                                                                         |
| visit_id         | `66c99da0-f213-4eb9-82f2-d79519bbaf5a`                                                                                      |
| visitor_token    | `5464363e-3013-42ea-b53e-8ca976bde807`                                                                                      |
| user_id          | `1`                                                                                                                         |
| ip               | `172.25.0.1`                                                                                                                |
| user_agent       | `Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.54 Safari/537.36` |
| referrer         | `http://localhost:3000/my-learning`                                                                                         |
| referring_domain | `localhost`                                                                                                                 |
| landing_page     | `http://localhost:3000/modules/alpha/content-pages/1`                                                                       |
| browser          | `Chrome`                                                                                                                    |
| os               | `Mac`                                                                                                                       |
| device_type      | `Desktop`                                                                                                                   |
| started_at       | `2022-05-30 08:55:12.346976`                                                                                                |



## Transactions


| Done | Feature                | Controllers and actions                  | Key                    | Path                                  |
| :--- | :---                   | :---                                     | :---                   | :---                                  |
| [x]  | Homepage               | `HomeController#index`                   | `home_page`            | `/`                                   |
| [x]  | Monitoring progress    | `LearningController#show`                | `learning_page`        | `/my-learning`                        |
| [x]  | Course overview        | `TrainingModulesController#index`        | `course_overview_page` | `/modules`                            |
| [x]  | Module overview        | `TrainingModulesController#show`         | `module_overview_page` | `/modules/{alpha}`                    |
| [x]  | Module content         | `ContentPagesController#show`            | `module_content_page`  | `/modules/{alpha}/content-pages/{1}`  |
| [x]  | Static page content    | `StaticController#show`                  | `static_page`          | `/example-page`                       |
| [x]  | Account completion     | `ExtraRegistrationsController#update`    | `user_registration`    | `/extra-registrations/{name,setting}` |
| [x]  | User profile           | `UserController#show`                    | `profile_page`         | `/my-account`                         |
| [x]  | User name change       | `UserController#update_name`             | `user_name_change`     | `/my-account/update-name`             |
| [x]  | User email change      | `UserController#update_email`            | `user_email_change`    | `/my-account/update-email`            |
| [x]  | User password change   | `UserController#update_password`         | `user_password_change` | `/my-account/update-password`         |
| [x]  | User postcode change   | `UserController#update_postcode`         | `user_postcode_change` | `/my-account/update-postcode`         |
| [x]  | User ofsted change     | `UserController#update_ofsted_number`    | `user_ofsted_change`   | `/my-account/update-ofsted-number`    |
| [x]  | Email address taken    | `RegistrationsController#create`         | `email_address_taken`  | `/users/sign-up`                      |
| [x]  | User inactivity logout | `ErrorsController#timeout`               | `error_page`           | `/timeout`                            |
| [x]  | 404 Error              | `ErrorsController#not_found`             | `error_page`           | `/404`                                |
| [x]  | 500 Error              | `ErrorsController#internal_server_error` | `error_page`           | `/500`                                |
| [ ]  | tbc                    |                                          |                        |                                       |


## To be completed

Incremental course progress events, recording results only where relevant.

Starting
- `module_start`
- `submodule_start`
- `topic_start`
- `formative_assessment_start`
- `summative_assessment_start`
- `confidence_check_start`

Stopping
- `module_complete`
- `submodule_complete`
- `topic_complete`
- `formative_assessment_complete`
- `summative_assessment_complete`, `{ success: true, score: 23 }`
- `confidence_check_complete`

Milestones
- `questionnaire_answer`, `{ success: true }`

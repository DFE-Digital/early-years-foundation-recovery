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
| referrer         | `http://localhost:3000/my-modules`                                                                                         |
| referring_domain | `localhost`                                                                                                                 |
| landing_page     | `http://localhost:3000/modules/alpha/content-pages/1`                                                                       |
| browser          | `Chrome`                                                                                                                    |
| os               | `Mac`                                                                                                                       |
| device_type      | `Desktop`                                                                                                                   |
| started_at       | `2022-05-30 08:55:12.346976`                                                                                                |



## Transactions


| Done | Feature                       | Controllers                                | Key                             | Path                                         |
| :--- | :---                          | :---                                       | :---                            | :---                                         |
| [x]  | Homepage                      | `HomeController`                           | `home_page`                     | `/`                                          |
| [x]  | Monitoring progress           | `LearningController`                       | `learning_page`                 | `/my-modules`                                |
| [x]  | Course overview               | `TrainingModulesController`                | `course_overview_page`          | `/modules`                                   |
| [x]  | Module overview               | `TrainingModulesController`                | `module_overview_page`          | `/modules/{alpha}`                           |
| [x]  | Module content                | `ContentPagesController`                   | `module_content_page`           | `/modules/{alpha}/content-pages/{1}`         |
| [x]  | Static page content           | `StaticController`                         | `static_page`                   | `/example-page`                              |
| [x]  | Account completion            | `Registration::RoleType{Other}sController` | `user_registration`             | `/registration/role-type`                    |
| [x]  | User profile                  | `UserController`                           | `profile_page`                  | `/my-account`                                |
| [x]  | User name change              | `UserController`                           | `user_name_change`              | `/my-account/update-name`                    |
| [x]  | User email change             | `UserController`                           | `user_email_change`             | `/my-account/update-email`                   |
| [x]  | User password change          | `UserController`                           | `user_password_change`          | `/my-account/update-password`                |
| [x]  | User postcode change          | `UserController`                           | `user_postcode_change`          | `/my-account/update-postcode`                |
| [x]  | User ofsted change            | `UserController`                           | `user_ofsted_change`            | `/my-account/update-ofsted-number`           |
| [x]  | Email address taken           | `RegistrationsController`                  | `email_address_taken`           | `/users/sign-up`                             |
| [x]  | User inactivity logout        | `ErrorsController`                         | `error_page`                    | `/timeout`                                   |
| [x]  | 404 Error                     | `ErrorsController`                         | `error_page`                    | `/404`                                       |
| [x]  | 500 Error                     | `ErrorsController`                         | `error_page`                    | `/500`                                       |
| [x]  | Module start                  | `ContentPagesController`                   | `module_start`                  | `/modules/{alpha}/content-pages/{intro}`     |
| [x]  | Module complete               | `TrainingModulesController`                | `module_complete`               | `/modules/{alpha}/certificate`               |
| [x]  | Questionnaire answered        | `QuestionnairesController`                 | `questionnaire_answer`          | `/modules/{alpha}/questionnaires/{path}`     |
| [x]  | Summative assessment start    | `QuestionnairesController`                 | `summative_assessment_start`    | `/modules/{alpha}/questionnaires/{path}`     |
| [x]  | Summative assessment complete | `AssessmentResultsController`              | `summative_assessment_complete` | `/modules/{alpha}/assessment-results/{path}` |
| [x]  | Confidence check start        | `QuestionnairesController`                 | `confidence_check_start`        | `/modules/{alpha}/questionnaires/{path}`     |
| [x]  | Confidence check complete     | `ContentPagesController`                   | `confidence_check_complete`     | `/modules/{alpha}/questionnaires/{path}`     |
| [x]  | User note created             | `NotesController`                          | `user_note_created`             | `/my-account/learning-log`                   |
| [x]  | User note updated             | `NotesController`                          | `user_note_updated`             | `/my-account/learning-log`                   |

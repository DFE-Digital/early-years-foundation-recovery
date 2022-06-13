# Key Performance Indicators

## Getting started

The [Ahoy](https://github.com/ankane/ahoy) gem records user transactions with MVC controllers in two tables.

> `Ahoy::Tracker.new(controller: self)`

## Data overview

Example event data from the `ahoy_events` table.

| Column     | Data                                                                                          |
| ---        | ---                                                                                           |
| id         | `95`                                                                                          |
| visit_id   | `7`                                                                                           |
| user_id    | `1`                                                                                           |
| name       | `Viewing 1`                                                                                   |
| properties | `{"id": "1", "action": "show", "controller": "content_pages", "training_module_id": "alpha"}` |
| time       | `2022-06-10 07:58:09.15539`                                                                   |


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
| landing_page     | `http://localhost:3000/modules/brain-development-in-early-years/content_pages/1`                                            |
| browser          | `Chrome`                                                                                                                    |
| os               | `Mac`                                                                                                                       |
| device_type      | `Desktop`                                                                                                                   |
| started_at       | `2022-05-30 08:55:12.346976`                                                                                                |



## Transactions

| Feature                             | Controllers and actions                  | Key                              | Data                                                                                          | Verb  | Path                                       |
| :---                                | :---                                     | :---                             | :---                                                                                          | :---  | :---                                       |
| Homepage                            | `HomeController#index`                   |                                  | `{}`                                                                                          | `GET` | `/`                                        |
| Completing the account registration | `ExtraRegistrationsController#edit`      |                                  | `{}`                                                                                          | `GET` | `/extra-registrations/{name,setting}/edit` |
| Monitoring progress                 | `LearningController#show`                |                                  | `{}`                                                                                          | `GET` | `/my-learning`                             |
| Course overview                     | `TrainingModulesController#index`        |                                  | `{}`                                                                                          | `GET` | `/modules`                                 |
| Module overview                     | `TrainingModulesController#show`         |                                  | `{}`                                                                                          | `GET` | `/modules/{alpha}`                         |
| View module content (implicit)      | `ContentPagesController#index`           | `View 1`                         | `{}`                                                                                          | `GET` | `/modules/{alpha}/content-pages`           |
| View module content (explicit)      | `ContentPagesController#show`            |                                  | `{"id": "1", "action": "show", "controller": "content_pages", "training_module_id": "alpha"}` | `GET` | `/modules/{alpha}/content-pages/{1}`       |
| Static page content                 | `StaticController#show`                  |                                  | `{}`                                                                                          | `GET` | `/privacy-policy`                          |
| User profile                        | `UserController#show`                    |                                  | `{}`                                                                                          | `GET` | `/my-account`                              |
| - edit name                         | `UserController#edit_name`               |                                  | `{}`                                                                                          | `GET` | `/my-account/edit-name`                    |
| - update name                       | `UserController#update_name`             | `name_changed`                   | `{}`                                                                                          | `PUT` | `/my-account/update-name`                  |
| - edit password                     | `UserController#edit_password`           |                                  | `{}`                                                                                          | `GET` | `/my-account/edit-password`                |
| - update password failed            | `UserController#update_password`         | `password_change_attempt_failed` | `{}`                                                                                          | `PUT` | `/my-account/update-password`              |
| - update password succeeded         | `UserController#update_password`         | `password_changed`               | `{}`                                                                                          | `PUT` | `/my-account/update-password`              |
| 404 Error                           | `ErrorsController#not_found`             |                                  | `{}`                                                                                          | `GET` | `/404`                                     |
| 500 Error                           | `ErrorsController#internal_server_error` |                                  | `{}`                                                                                          | `GET` | `/500`                                     |
| User inactivity logout              | `ErrorsController#timeout`               |                                  | `{}`                                                                                          | `GET` | `/timeout`                                 |


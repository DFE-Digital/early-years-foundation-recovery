# Early Years Recovery

A Ruby on Rails 7 app







## Docker

Containerised services in development have exposed ports for local access.

- `bin/docker-build` creates tagged docker images
- `bin/docker-dev` starts `Procfile.dev`, containerised equivalent of `bin/dev`
- `bin/docker-rails console` drops into a running dev environment or starts one
- `bin/docker-rspec -f doc` runs the test suite with optional arguments

Permissions on any files generated within Docker, in the development environment with a mounted volume, will be owned by root.
You can correct the permissions in your local working directory by running `bin/docker-files`.

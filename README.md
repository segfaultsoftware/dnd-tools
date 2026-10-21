# TTRPG Tools & Campaign Management

Rails 8.1.4 application foundation for the TTRPG Tools & Campaign Management
application.

## Runtime

- Ruby 4.0.7 (pinned in `.ruby-version`)
- PostgreSQL 18.6 for development and test

Install dependencies with `bundle install`, prepare the database with
`bin/rails db:prepare`, and run the test suite with `bundle exec rspec`.

The development and test databases use PostgreSQL. The historical NPC generator
is preserved under `archive/` and is not part of this Rails application.

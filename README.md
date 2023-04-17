# OnlineCheckIn API

API to store and retrieve confidential development files (configuration, credentials)

## Routes

All routes return Json

- GET  `/`: Root route shows if Web API is running
- GET  `api/v1/households/[house_id]/documents/[doc_id]`: Get a document
- GET  `api/v1/households/[house_id]/documents`: Get list of documents for household
- POST `api/v1/households/[ID]/documents`: Upload document for a household
- GET  `api/v1/households/[ID]`: Get information about a household
- GET  `api/v1/households`: Get list of all household
- POST `api/v1/households`: Create new household

## Install

Install this API by cloning the *relevant branch* and use bundler to install specified gems from `Gemfile.lock`:

```shell
bundle install
```

Setup development database once:

```shell
rake db:migrate
```

## Execute

Run this API using:

```shell
puma
```

## Test

Setup test database once:

```shell
RACK_ENV=test rake db:migrate
```

Run the test specification script in `Rakefile`:

```shell
rake spec
```

## Release check

Before submitting pull requests, please check if specs, style, and dependency audits pass:

```shell
rake release?
```
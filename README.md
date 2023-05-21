<<<<<<< HEAD
# NMC_OnlineCheckIn-api
Project for Security Service
Currently, large-scale community meetings in Taiwan are mostly fixed-point. However, finding a suitable venue for a three-hour meeting with hundreds of people is inconvenient, time-consuming, and expensive. To address this issue, we propose an online voting platform that enables neighborhood communities to hold their meetings online. This system will have two main features: online check-in and live-streaming.

Online Check-in:
The online check-in feature will allow members to sign in and participate in meetings remotely, improving efficiency and accessibility. It will also provide the necessary information for the meeting, such as the square footage stated in the property deed, which is crucial since, according to the law, more than two-thirds of the distinguished owners must attend the meeting to make it legal.

## Routes
All routes return JSON
* GET `/`:Root route shows if Web API is running
* GET `api/v1/document/`: returns all confiugration IDs
* GET `api/v1/document/[ID]`: returns details about a single document with given ID
* POST `api/v1/document/`: creates a new document

## Install
Install this API by cloning the relevant branch and use bundler to install specified gems from `Gemfile.lock`:

```
bundle install
```

## Test

Run the test script:

```shell
ruby spec/api_spec.rb
=======
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
>>>>>>> 5-deployable
```

## Execute

Run this API using:

```shell
puma
```
<<<<<<< HEAD
=======

## Test

Setup test database once:

```shell
RACK_ENV=test rake db:migrate
```

Run the test specification script in `Rakefile`:

```shell
rake spec
```
## Develop/Debug

Add fake data to the development database to work on this project:

```shell
rake db:seed
```
## Execute

Launch the API using:

```shell
puma
```
## Release check

Before submitting pull requests, please check if specs, style, and dependency audits pass:

```shell
rake release?
```
>>>>>>> 5-deployable

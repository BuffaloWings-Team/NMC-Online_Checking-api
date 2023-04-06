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

# Test

Run the test script:

```shell
ruby spec/api_spec.rb
```

## Execute

Run this API using:

```shell
puma
```

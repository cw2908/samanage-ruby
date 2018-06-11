# Samanage Ruby Gem
[![Gem Version](https://badge.fury.io/rb/samanage.svg)](https://badge.fury.io/rb/samanage)
[![Build Status](https://semaphoreci.com/api/v1/projects/8e1f8e7f-6e09-4dad-ac10-e9f41fa61b7d/1437435/shields_badge.svg)](https://semaphoreci.com/cw2908/samanage-ruby)
## Requirements
- Ruby >= 2.3


## Installation
`gem install samanage`




## Usage
### Basic Queries

Initialize API controller
```ruby
    api_controller = Samanage::Api.new(token: 'abc123')
```

- Create a user
```ruby
    user = {user: { name: 'John Doe', email: 'john.doe@example.com'}}
    api_controller.create_user(payload: user)
```


- Find a user by email
```ruby
    my_user = api_controller.find_user_by_email(email: 'user@example.com')
```


- Update incident by ID
```ruby
    incident_data = {incident: { priority: 'Critical' }}
    incident_update = api_controller.update_incident(id: 123, payload: incident_data)
```


- Update hardware
```ruby
hardware = {hardware: {name: 'My Computer'}}
result = api_controller.update_hardware(id: 123, payload: hardware)
```

- Use Filters
```ruby
    incidents_updated_today = @samanage.incidents(options: {'updated' => 1})
    expired_hardwares = @samanage.hardwares(options: {'warranty_status[]' => 'Expired'})
```





Executing an api query will return a Hash with the following keys:
- `:response`*:* unparsed http response
- `:code`*:* http status code
- `:json`*:* Samanage API json response
- `:headers`*:* Response headers
- `:total_pages`*:* Total pages
- `:total_count`*:* Total count of records
- `:data`*:* Hash containing response body





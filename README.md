# Samanage Ruby Gem
[![Gem Version](https://badge.fury.io/rb/samanage.svg)](https://badge.fury.io/rb/samanage)
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


### Listing and Searching
- Find All Users
```ruby
users = api_controller.users # returns all users
```
- Filtering Incidents matching custom field and updated in the last 7 days
```ruby
incidents = api_controller.incidents(options: {'Custom Field' => 'Some Value', 'updated[]' => 7})
```

- Listing / Searching also responds to blocks
```ruby
api.controller.users(options: {'Some Filter' => 'Some Value'}) do |user|
  if user['email'].match(/something/)
    foo(bar: bar, user: user)
  else
    puts "User #{user['email']} did not match"
  end
end
```



Executing an api query will return a Hash with the following keys:
- `:response`*:* unparsed http response
- `:code`*:* http status code
- `:json`*:* Samanage API json response
- `:headers`*:* Response headers
- `:total_pages`*:* Total pages
- `:total_count`*:* Total count of records
- `:data`*:* Hash containing response body





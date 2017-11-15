# Samanage Ruby Gem
[![Gem Version](https://badge.fury.io/rb/samanage.svg)](https://badge.fury.io/rb/samanage)
[![Build Status](https://semaphoreci.com/api/v1/projects/8e1f8e7f-6e09-4dad-ac10-e9f41fa61b7d/1437745/badge.svg)](https://semaphoreci.com/cw2908/samanage-ruby)
## Requirements
- Ruby >= 2.3


## Installation
`gem install samanage`

#### Linux (CentOS)
- `sudo yum install gcc-c++`
- `sudo yum install ruby-devel`
- `sudo gem install samanage`




## Usage
### Basic Queries

Initialize API controller
```ruby
    api_controller = Samanage::Api.new(token: 'abc123')
```

- Find a user by email
```ruby
    user_query = api_controller.execute(http_method: 'get', path: 'users.json?email=example@gmail.com')
```


- Update incident by ID
```ruby
    incident_data = {incident: { priority: 'Critical' }}.to_json
    incident_update = api_controller.execute(http_method: 'put', path: 'incidents/123.json', payload: incident_data)
```

- Update hardware
```ruby
hardware = {'hardware':{'name':'My Computer'}}
result = api_controller.update_hardware(id: 123, payload: hardware)
```





Executing an api query will return a Hash with the following keys:
- `:response`*:* unparsed http response
- `:code`*:* http status code
- `:json`*:* Samanage API json response
- `:headers`*:* Response headers
- `:total_pages`*:* Total pages
- `:total_count`*:* Total count of records
- `:data`*:* Hash containing response body





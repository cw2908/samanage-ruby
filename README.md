# Samanage Ruby Gem

## Requirements
- Ruby >= 2.3.1

## Installation
`gem install samanage`
#### Linux (CentOS)
- `sudo yum install gcc-c++"`
- `sudo yum install ruby-devel`
- `sudo gem install`




## Usage
### Queries

```ruby
    api_controller = Samanage::Api.new(token: api_token)
    user_query = api_controller.execute(http_method: 'get',
     path: 'users.json')
```
Returns query returns a Hash with keys:
- `:response`*:* unparsed http response
- `:code`*:* http status code
- `:json`*:* Samanage API json response
- `:headers`*:* Response headers
- `:total_pages`*:* Total pages
- `:total_count`*:* Total count of records
- `:data`*:* Hash containing response body

### Function examples
#### Return all Samanage Users
```ruby
users = api_controller.collect_users
```

#### Update hardware
```ruby
hardware = {'hardware':{'name':'My Computer'}}
result = api_controller.update_hardware(id: 123, payload: hardware)
```
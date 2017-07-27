# samanage-ruby

## Requirements
- Ruby >= 2.3.1

## Installation
gem install samanage



## Usage
### Queries

```ruby
    api_controller = Samanage::Api.new(token: api_token)
    query = api_controller.execute(http_method: 'get',
     path: 'users.json')
```
Returns query returns a hash with keys:
- :response => unparsed `http` response
- :code => http status code
- :json => Samanage API json response
- :headers => `http` response.headers
- :total_pages => total pages
- :total_count => total count of records
- :data => `Hash` of response body

### Function examples
#### Return all Samanage Users
```ruby
users = api_controller.collect_users
users.each{|user| puts "Email: #{user['email']}"}
```

#### Update hardware
```ruby
hardware = {'hardware':{'name':'My Computer'}}
result = api_controller.update_hardware(id: 123, payload: hardware)
```
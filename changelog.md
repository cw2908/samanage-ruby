### 2.1.20

- Added tasks
- Updated bundle & gems

### 2.1.19

- +Linting

### 2.1.18

- Force multipart for attachments
- Custom sleep time
- Added catching all errors
- Normalizing stout

### 2.1.17

- Retry all errors
- Ability to configure retry count & wait time.
- Normalize messages

### 2.1.16

- Use options where callbacks could be sent

### 2.1.15

- Use options in find methods

### 2.1.14

- Swap header merging

### 2.1.13

- Pass Query params separate from Body
- Add coverage for `{add_calbacks: true}` option
- Add Release support

### 2.1.12

- Add vendor support
- Close opened files

### 2.1.11

- Update runtime

### 2.1.10

- Attachments for Windows
- Handle Socket Errors

### 2.1.09

- Updated HTTParty to 0.16.4
- Optimize heavy audit+layout incident collection
- Adding purchase order support
- Added support for attachments
- Fix content type inheritance
- Use body instead of query params
- Handle HTTPTooManyRequests

### 2.1.08

- Correct Message

### 2.1.07

- Added problems

### 2.1.06

- Added time track support

### 2.1.05

- Adding new error checks
- Using Faker for tests

### 2.1.04

- params bug fix

### 2.1.03

- Use paths

### 2.1.02

- Use parmas in all collections

### 2.1.01

- Added solutions

### 2.1.0

- Use `URI###encode_www_form`

### 2.0.04

- Fix case sensitivity relationships

### 2.0.03

- Bugfix for custom fields (fix httparty version)

### 2.0.0

- Support for responding to blocks in all paginated collection methods
- Added Changes (itsm)

### 1.9.35

- Solve warnings

### 1.9.34

- Solve warnings

### 1.9.33

- Using new cert

### 1.9.32

- Adding layout long for single incident
- Adding attachment downloads

### 1.9.31

- Alias original comment method
- Remove (keyword: nil)
- Collapse error retry output

### 1.9.3

- Handle HTTP Read Timeout

### 1.9.2

- Adding delete functionality for modules Contracts, Departments, Groups, Hardwares, Incidents, Mobiles, Other_assets, Sites, Users

### 1.9.1

- Adding items to contracts & faster tests

### 1.9.0

- Adding contracts

### 1.8.91

- Group case sensitivity fix

### 1.8.9

- Adding output verbosity for collection methods

### 1.8.8

- Base level .execute delete functionality
- Error message for invalid http methods
- Added audit_archive to incident options

### 1.8.7

- Fixing retry bug

### 1.8.6

- Removing layout=long verbosity

### 1.8.5

- Adding option for incidents layout=long

### 1.8.3

- Additional Request Timeout retry support
- Support for non-parsed responseq
- Moving non object specific methods to samanage/api/utils
- Added activation emails

### 1.8.2

- Adding Category support
  ###1.8.1
- More flexible membership adding
- Collection method aliasing for simpler api (old methods will be removed in v2.0)
  ###1.8.0
- Adding coverage for invalid api requests
  ###1.7.9
- Solving eu datacenter support against base_url
  ###1.7.8
- Fixing nil condition in user_id methods
  ###1.7.6
- Adding group_id find methods for group name and user email
  ###1.7.5
- Adding site, department, group creation
  ###1.7.4
- Solving admin listing issue
  ###1.7.2
- Catching refused connections as Samanage::Error
  ###1.7.1
- Client Side SSL certificate Forced
  ###1.7.0
- Switched to HTTParty
- Payload now responds to `Hash`. `Strings` will be parsed using `JSON.parse(payload)`
  ###1.6.9
- Added support for Mobile Devices

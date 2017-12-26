# 1.8.5
- Adding option for incidents layout=long

# 1.8.3 
- Additional Request Timeout retry support
- Support for non-parsed response
- Moving non object specific methods to samanage/api/utils
- Added activation emails

# 1.8.2
- Adding Category support

#1.8.1
- More flexible membership adding
- Collection method aliasing for simpler api (old methods will be removed in v2.0)

#1.8.0
- Adding coverage for invalid api requests

#1.7.9
- Solving eu datacenter support against base_url
#1.7.8
- Fixing nil condition in user_id methods

#1.7.6
- Adding group_id find methods for group name and user email

#1.7.5
- Adding site, department, group creation

#1.7.4
- Solving admin listing issue

#1.7.2
- Catching refused connections as Samanage::Error

#1.7.1
- Client Side SSL certificate Forced

#1.7.0
- Switched to HTTParty
- Payload now responds to `Hash`. `Strings` will be parsed using `JSON.parse(payload)`

#1.6.9
- Added support for Mobile Devices
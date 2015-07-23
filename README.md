# Chatter

This project is a POC of an iOS (Swift) Program that provides user registration, authentication, and Chat using the Parse Service.


## Requirements
* XCode 6.4 (minimum)
* iOS 8.0 (minimum)
* CocoaPods 0.38.0


## Testing Push Notifications:
```bash
curl -X POST \
  -H "X-Parse-Application-Id: ${PARSE_APPLICATION_ID}" \
  -H "X-Parse-REST-API-Key: ${PARSE_REST_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
        "where": {
          "deviceType": "ios"
        },
        "data": {
          "alert": "Hello World!"
        }
      }' \
  https://api.parse.com/1/push
```

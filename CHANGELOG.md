## 1.0.9

* Fix strict analyzer warning caused by an unreachable switch default branch
* Fix binary responses to return raw `bodyBytes` without UTF-8 decoding
* Send real multipart form-data requests instead of only setting the header
* Add multipart file upload support via `files: List<http.MultipartFile>`
* Prevent invalid automatic retries for finalized multipart file uploads
* Allow injecting a custom `http.Client` for reuse and testing
* Correct README examples and document request/response behavior

## 1.0.8

* UTF-8 encoding fix
* Type support

## 1.0.7

* fix json content type when send body

## 1.0.6

* fix send body

## 1.0.5

* fix content type

## 1.0.4

* Small fixes

## 1.0.3

* Add response body type

## 1.0.2

* Small fixes

## 1.0.1

* Small fixes

## 1.0.0

* Easy HTTP first release

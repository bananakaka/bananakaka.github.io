http [--json][--form] [--pretty {all,colors,format,none}]

    [--style STYLE] [--print WHAT] [--verbose] [--headers] [--body]
    [--stream] [--output FILE] [--download] [--continue]
    [--session SESSION_NAME_OR_PATH | --session-read-only SESSION_NAME_OR_PATH]
    [--auth USER[:PASS]] [--auth-type {basic,digest}]
    [--proxy PROTOCOL:PROXY_URL] [--follow] [--verify VERIFY]
    [--cert CERT] [--cert-key CERT_KEY] [--timeout SECONDS]
    [--check-status] [--ignore-stdin] [--help] [--version]
    [--traceback] [--debug]
    [METHOD] URL [REQUEST_ITEM [REQUEST_ITEM ...]]

METHOD (GET, POST, PUT, DELETE, ...)
METHOD参数可以忽略，如果带查询参数默认用post，不带参数用get
$ http example.org               # => GET
$ http example.org hello=world   # => POST

URL
如果url不包含协议头，默认加'http://'
localhost简写
$ http :3000                    # => http://localhost:3000
$ http :/foo                    # => http://localhost/foo

REQUEST_ITEM
':' HTTP头
http://httpie.org  Cookie:foo=bar  User-Agent:bacon/1.0

'==' url 后面追加参数
http www.google.com search=='HTTPie logo' tbm==isch

'=' Data fields to be serialized into a JSON object (with --json, -j) or form data (with --form, -f):
http PUT example.org name=HTTPie language=Python description='CLI HTTP client'
对应的request内容：
PUT / HTTP/1.1
Accept: application/json
Accept-Encoding: gzip, deflate
Content-Type: application/json
Host: example.org
```
{
    "name": "HTTPie",
    "language": "Python",
    "description": "CLI HTTP client"
}
```
':=' Non-string fields or embed Raw JSON data fields (only with --json, -j):
age:=29 married:=false hobbies:='["http", "pies"]'

'=@' A data field like '=', takes a text file path and embeds its content:
description=@about-john.txt

':=@' A raw JSON field like ':=', but takes a file path and embeds its content:
bookmarks:=@bookmarks.json

for example:
http PUT api.example.com/person/1 \
    name=John \
    age:=29 married:=false hobbies:='["http", "pies"]' \  # Raw JSON
    description=@about-john.txt \   # Embed text file
    bookmarks:=@bookmarks.json      # Embed JSON file

request content:
PUT /person/1 HTTP/1.1
Accept: application/json
Content-Type: application/json
Host: api.example.com
```
{
    "age": 29,
    "hobbies": [
        "http",
        "pies"
    ],
    "description": "John is a nice guy who likes pies.",
    "married": false,
    "name": "John",
    "bookmarks": {
        "HTTPie": "http://httpie.org",
    }
}
```
'@' Form file fields (only with --form, -f):
field@/dir/file
screenshot@~/Pictures/img.png. The presence of a file field results in a multipart/form-data request.

Predefined Content Types:
--json, -j(default)
The Content-Type and Accept headers are set to application/json

--form, -f
The Content-Type is set to application/x-www-form-urlencoded (if not specified). The presence of any file fields results in a multipart/form-data request.


http -f POST 121.18.230.182/order_create product_id=2512 address_id=249681 Authorization:'Token 1462085949-a710445abeb39107-14690877' X-Same-Request-ID:ac383a58-13d2-449e-b3f0-7958308acd0a Host:payment.ohsame.com Content-Length:34 User-Agent:same/433 X-same-Device-UUID:864264020126014 Advertising-UUID:864264020126014 X-same-Client-Version:433






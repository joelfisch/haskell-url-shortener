# haskell-url-shortener

The service is deployed at https://haskell-url-shortener.herokuapp.com/shorten
and can be used as following:

## Create short link

Note: Only URLs with the scheme http and https are allowed. URLs with
a user/password are not supported.

The shortId has to be alphanumeric and can be used only once.

Example:

```
POST https://haskell-url-shortener.herokuapp.com/shorten
Content-Type application/json

{"url":"https://google.ch","shortId":"goo"}
```

## Use a short link

Append the shortId used while creating and append it to the URL of the service
(https://haskell-url-shortener.herokuapp.com/{shortId}).

Example:

```
GET https://haskell-url-shortener.herokuapp.com/goo
```

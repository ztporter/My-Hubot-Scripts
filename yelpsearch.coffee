# Description:
#   Access Yelp API to search for a type of food around Lexington, KY
#
# Dependencies:
#   oauth-1.0a
#   request
#
# Configuration:
#   None
#
# Commands:
#   i'm hungry for (type of food) or "let's eat (type of food)"
#   - returns restaurant results 
#   from yelp api for that food type in the specified area
#   (default lexington, ky) up to the search limit (default is 5)

#Fun Dependencies
OAuth = require('oauth-1.0a')
request = require('request')

#OAuth Credentials
CONSUMER_KEY = "R7XRZ8DUqaQWbyK5CN7CVg"
CONSUMER_SECRET = "25EBf2VflT1lXIKVAhQ7wG0G5l0"
TOKEN = "l83vEQNb3Ppk7vs-3nIT6VtCi-ASKZoE"
TOKEN_SECRET = "y77APbNbMz4-KJLrPPZinI0LyXQ"

#Default Search Parameters
API_HOST = "http://api.yelp.com"
SEARCH_PATH = "/v2/search"
SEARCH_LIMIT = 5
CATEGORY_FILTER = "restaurants"
SEARCH_TERM = "good"
SEARCH_LOCATION = "lexington kentucky"
search_url = API_HOST+SEARCH_PATH

#Search function calls Yelp's API with the provided search url and displays the result
search = (msg) ->
 oauth = OAuth({
		consumer: {
			public: CONSUMER_KEY,
			secret: CONSUMER_SECRET
		},
		signature_method: "HMAC-SHA1"
	});

 request_data = {
  url: search_url,
  method: 'GET',
  data: { 
  }
 };

	token = {
		public: TOKEN,
		secret: TOKEN_SECRET
	};

#Generate signed request
 request({
  url: request_data.url,
  method: request_data.method,
  form: request_data.data,
  headers: oauth.toHeader(oauth.authorize(request_data, token))
  }, (error, response, body) ->
   #Format result in a coherent way
   if body is undefined
    msg.send "Oops there's a problem with the interwebs"
    return
   x = JSON.parse(body).businesses
   if x is undefined
    msg.send "Oops error: " + JSON.parse(body).error.text
    return
   if x.length is 0
    msg.send "Sorry, no results found"
    return
   output = "My suggestions are ..." + "\n" + "\n"
   i = 0
   while i < x.length
    output += x[i].name
    output += "     Rating: " + x[i].rating + "\n"
    output += "url: " + x[i].url + "\n" + "\n"
    i += 1
   msg.send output
 )

listen = (msg) ->
 foodType = msg.match[1]
 SEARCH_TERM = foodType
 if foodType is "fast food"
  msg.reply "You can do better..."
 else
  search_url = API_HOST+SEARCH_PATH+"?term="+SEARCH_TERM+"&category_filter="+CATEGORY_FILTER+"&limit="+SEARCH_LIMIT+"&location="+SEARCH_LOCATION+"&sort=0"
  search (msg)

module.exports = (robot) ->
 robot.hear /I'm hungry for (.*)/i, listen
 robot.hear /let's eat (.*)/i, listen
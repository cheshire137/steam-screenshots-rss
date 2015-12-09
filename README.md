# Steam Screenshots RSS

A Sinatra app that produces an RSS feed of a user's Steam screenshots.

## How to Run

    bundle
    rackup

Visit [localhost:9292](http://localhost:9292/) to see an RSS feed of my Steam screenshots. Pass the `user` parameter to specify a different Steam user name, e.g., `http://localhost:9292?user=mySteamName`.

## How it Works

Steam has a [web API](https://developer.valvesoftware.com/wiki/Steam_Web_API),
but it doesn't include any way of getting a user's screenshots. Ruby and
Mechanize to the rescue! This script will scrape a
[user's screenshot page](http://steamcommunity.com/id/cheshire137/screenshots/?appid=0&sort=newestfirst&browsefilter=myfiles&view=grid)
and grab the screenshots. The screenshots are then listed in an RSS feed so
you can consume it with, say, [IFTTT](https://ifttt.com).

## IFTTT Recipe

Deploy this app to a server, [Heroku](https://dashboard.heroku.com/apps) is
pretty easy. Then, set up a recipe on IFTTT with the Feed channel. Set the URL
to wherever you deployed this app. Be sure to pass the `user` parameter to set
your Steam name! Choose 'New feed item' for the IFTTT trigger.

For a Tumblr recipe, the following works:

![Tumblr IFTTT recipe](https://raw.githubusercontent.com/cheshire137/steam-screenshots-rss/master/ifttt-screenshot.png)

Ruby Nestoria API Library
=========================

This is a simple library designed to facilitate the usage of the Nestoria API. The library supports all current Nestoria services, including:

  * nestoria.com.au
  * nestoria.com.br
  * nestoria.de
  * nestoria.es
  * nestoria.fr
  * nestoria.in
  * nestoria.it
  * nestoria.co.uk

Usage
=====

Initialize
----------

To initialize the library call new with the TLD of Nestoria service you wish to use.

    require 'nestoria/api'
    Nestoria::Api.new(:uk)

Echo
----

The echo command simply sends back any data you give it along with Nestoria's response headers:

    Nestoria::Api.new(:uk).echo :foo => "bar"
    # {"created_unix"=>1294588256, "encoding"=>"json", "action"=>"echo", "version"=>"1.19", "status_text"=>"OK", "status_code"=>"200", "foo"=>"bar", "sort"=>"nestoria_rank", "created_http"=>"Sun, 09 Jan 2011 15:50:56 GMT"}

Search
------

To search Nestoria's property listings call Nestoria::Api#search along with a hash of parameters specifying the search values. The keys are the same as those listed on the Nestoria API site here: [http://www.nestoria.co.uk/help/api-search-listings](http://www.nestoria.co.uk/help/api-search-listings)

keywords and keywords\_exclude take an Array object instead of a comma separated list. updated\_min can take a Time object instead of a UNIX timestamp.

    Nestoria::Api.new(:uk).search :listing_type => "buy", :place_name => "Wimborne", :keywords => ["off_street_parking", "unfurnished"]
    
You should receive a hash containing all the values in the Nestoria response, further details can be found on the link above.

Keywords
--------

For a list of valid keywords that can be used with the keywords and keywords\_exclude parameter in the search call Nestoria::Api#keywords. This will give you a set of keys and friendly names.

    Nestoria::Api.new(:uk).keywords
    # {"terrace"=>"Terrace", "studio"=>"Studio", "refurbished"=>"Refurbished", "patio"=>"Patio" ...

Metadata/Average House Prices
-----------------------------

There's also support for fetching the average house price information on an area, just use Nestoria::Api#metadata with a set of location parameters.

    Nestoria::Api.new(:uk).metadata :south_west => [50.965, -5.504], :north_east => [50.156, -5.136]

Caching
------

If you want to cache your queries, so that you won't hit nestoria as often
and at the same time speed up the process of getting respones, 
you can enable caching by initializing the Api with additional parameters. 

    Nestoria::Api.new(:uk, use_cache, max_age=5*60)
    #e.g. Nestoria::Api.new(:uk, true)
    #This will enable caching a response for 5 minutes 
    # or
    Nestoria::Api.new(:uk, true, 0.5)
    #will enable caching for 0.5 seconds

Contributing to Nestoria API Library
====================================
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

Copyright
=========

Copyright (c) 2011 Dan Wentworth. See LICENSE.txt for
further details.


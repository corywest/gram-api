# Anagram API

## Overview
This API allows a user to search through an English dictionary and find any anagrams that may exist. No idea what an anagram is? Take the red pill and look at this Wikipedia [article](https://www.wikiwand.com/en/Anagram).

## Getting Started
1. You'll want to seed your database before continuing. You can easily do so by running this command at the root of the project: `rake anagram:add_dictionary`
2. At the root of the project, run `bundle install` to load your gems
3. Once you're done with both of those items, run `rails s` at the root of the project and your API server will fire up

----

## How to use the API

#### Please note: If consuming this API locally, we assume that your root url will be http://localhost:3000

### GET Requests

#### Get list of anagrams:

* **URL** `/anagrams/:word`
* **Method:** `GET`
* **Optional Params:**
   `limit=[integer]`
   `proper_noun=[boolean]`
* **Success Response:**
  * **Code:** 200 <br />
  * **Content:** `{ "words": ["read", "dear", "dare"] }`
* **Example:** `curl -i http://localhost:3000/anagrams/read.json`

#### Get word information:

* **URL** `/word_info`
* **Method:** `GET`
* **Optional Params:** N/A
* **Success Response:**
  * **Code:** 200 <br />
    **Content:** `{"total_word_count":235886,"min_length":1,"max_length":24,"median":9,"average_length":9}`
* **Example:** `curl -i http://localhost:3000/word_info.json`

#### Check if group of words are anagrams:

* **URL** `/anagram_check`
* **Method:** `GET`
* **Optional Params:** N/A
* **Data Params:** `"words": ["read", "dear", "dare"]`
* **Success Response:**
  * **Code:** 200 <br />
    **Content:** `{ anagram_pair : true }`
* **Example:** `curl -i -X GET -d '{ "words": ["read", "dear", "dare"] }' http://localhost:3000/anagram_check.json`

#### Return lists of words with most anagrams:

* **URL** `/most_anagrams`
* **Method:** `GET`
* **Optional Params:** N/A
* **Success Response:**
  * **Code:** 200 <br />
    **Content:** `{ anagrams: [ ["A", "B", "C"], ["X", "Y"], ["Z"] ] }`
* **Example:** `curl -i http://localhost:3000/most_anagrams.json`

#### Return lists of anagrams by group size:

* **URL** `/anagram_groups`
* **Method:** `GET`
* **Optional Params:** `size=[integer]`
* **Success Response:**
  * **Code:** 200 <br />
    **Content:** `{ "anagrams": ["X"] }`
* **Example:** `curl -i http://localhost:3000/anagram_groups?size=1`

### POST Requests

#### Adds new word to the dictionary:

* **URL** `/words`
* **Method:** `POST`
* **Optional Params:** N/A
* **Success Response:**
  * **Code:** 201 <br />
* **Data Params**: `'{ "words": ["read", "dear", "dare"] }'`
* **Example:** `curl -i -X POST -d '{ "words": ["read", "dear", "dare"] }' http://localhost:3000/words.json`
  
  
### DELETE Requests

#### Deletes a singlular word from the dictionary:

* **URL** `/words/:word`
* **Method:** `DELETE`
* **Optional Params:** N/A
* **Success Response:**
  * **Code:** 200 <br />
* **Example:** `curl -i -X DELETE http://localhost:3000/words/read.json`
  
#### Delete a word and associated anagrams:

* **URL** `/delete_associated_anagrams/:word`
* **Method:** `DELETE`
* **Optional Params:** N/A
* **Success Response:**
  * **Code:** 202 <br />
* **Example:** `curl -i http://localhost:3000/delete_associated_anagrams/car.json`
  
#### Delete all words:

* **URL** `/words`
* **Method:** `DELETE`
*  **URL Params** `N/A`
* **Success Response:**
  * **Code:** 204 <br />
* **Example:** `curl -i -X DELETE http://localhost:3000/words.json`

----

### Data store
If you have ever used Ruby on Rails before, you may have used it's library for storing data called ActiveRecord. ActiveRecord makes it pretty easy to work with Relational SQL Databases like MySQL and Postgres. The decision to use ActiveRecord made the process of creating a Rails API much easier. 

### Cool features to have in the future
1. Since a few API calls require the entire dictionary to be called in order to return some data to our liking, it'd be great to speed up this process a bit. Some ideas would be to cache requests, so that any additional ones would be much faster in the future. If the data collection changes, then we can bust the cache to allow for any updated information to be served. Since the dictionary doesn't change too often, we can safely assume that we can bust the cache on a specified cadence that could be decided by the Anagram API team. 

2. It would also be great if we could implement a way to batch results if needed. Sometimes a user may not want all of the results, all of the time. With batching, we could also paginate any results that we get from the database. Batching could also work with deletes as well. Since there are so many words, a large delete could be done in batches and also with scattered requests to give the database some time to breath.

### Design overview
During the design of the API, there was an attempt to keep the controllers away from any business logic. It's best to keep our controllers skinny. This allows us to use simple calls that follow a step by step flow and gives the user the results they want. The business logic was contained on the model itself. Since we are taking incoming data directly from ActiveRecord, we can safely put any additional and complex logic on the model itself. This will keep our controllers nice, clean, and full of model methods that can be reused from anywhere.

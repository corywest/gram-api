#!/usr/bin/env ruby

require 'json'
require_relative 'anagram_client'
require 'test/unit'
require 'uri'
# capture ARGV before TestUnit Autorunner clobbers it

class TestCases < Test::Unit::TestCase

  # runs before each test
  def setup
    @client = AnagramClient.new(ARGV)

    # add words to the dictionary
    @client.post('/words.json', nil, {"words" => ["read", "dear", "dare"] }) rescue nil
  end

  # runs after each test
  def teardown
    @client.delete('/words.json') rescue nil
  end

  def test_adding_words
    res = @client.post('/words.json', nil, {"words" => ["read", "dear", "dare"] })

    assert_equal('201', res.code, "Unexpected response code")
  end

  def test_fetching_anagrams
    res = @client.get('/anagrams/read.json')
    assert_equal('200', res.code, "Unexpected response code")
    assert_not_nil(res.body)

    body = JSON.parse(res.body)

    assert_not_nil(body['anagrams'])
    expected_anagrams = %w(dare dear read)
    assert_equal(expected_anagrams, body['anagrams'].sort)
  end

  def test_fetching_anagrams_with_limit
    res = @client.get('/anagrams/read.json', 'limit=1')
    assert_equal('200', res.code, "Unexpected response code")

    body = JSON.parse(res.body)

    assert_equal(1, body['anagrams'].size)
  end

  def test_fetch_for_word_with_no_anagrams
    res = @client.get('/anagrams/zyxwv.json')
    assert_equal('200', res.code, "Unexpected response code")

    body = JSON.parse(res.body)

    assert_equal(0, body['anagrams'].size)
  end

  def test_deleting_all_words

    res = @client.delete('/words.json')

    assert_equal('204', res.code, "Unexpected response code")

    # should fetch an empty body
    res = @client.get('/anagrams/read.json')

    assert_equal('200', res.code, "Unexpected response code")

    body = JSON.parse(res.body)

    assert_equal(0, body['anagrams'].size)
  end

  def test_deleting_all_words_multiple_times

    3.times do
      res = @client.delete('/words.json')

      assert_equal('204', res.code, "Unexpected response code")
    end

    # should fetch an empty body
    res = @client.get('/anagrams/read.json', 'limit=1')
    assert_equal('200', res.code, "Unexpected response code")

    body = JSON.parse(res.body)

    assert_equal(0, body['anagrams'].size)
  end

  def test_deleting_single_word
    res = @client.delete('/words/dear.json')
    assert_equal('200', res.code, "Unexpected response code")

    res = @client.get('/anagrams/read.json')
    assert_equal('200', res.code, "Unexpected response code")

    body = JSON.parse(res.body)

    assert_equal(['read', 'dare'], body['anagrams'])
  end

  def test_word_info
    res = @client.get('/word_info.json')

    assert_equal('200', res.code, "Unexpected response code")
    assert_not_nil(res.body)

    body = JSON.parse(res.body)

    assert_not_nil(body)
    assert_equal(body['total_word_count'], 3)
    assert_equal(body['min_length'], 4)
    assert_equal(body['max_length'], 4)
    assert_equal(body['median'], 4)
    assert_equal(body['average_length'], 4)
  end

  def test_delete_word_and_all_associated_words
    res = @client.delete('/delete_associated_anagrams/read')

    assert_equal('404', res.code, "Unexpected response code")
    body = JSON.parse(res.body)

    assert_equal([], body['anagrams'])

    res = @client.get('/anagrams/read.json')
    body = JSON.parse(res.body)
    assert_equal([], body['anagrams'])

    res = @client.get('/anagrams/dear.json')
    body = JSON.parse(res.body)
    assert_equal([], body['anagrams'])

    res = @client.get('/anagrams/dare.json')
    body = JSON.parse(res.body)
    assert_equal([], body['anagrams'])
  end

  def test_fetching_proper_noun_anagrams
    @client.post('/words.json', nil, {"words" => ["Aa", "aa"] }) rescue nil

    res = @client.get('/anagrams/Aa.json', 'proper_noun=true')
    assert_equal('200', res.code, "Unexpected response code")

    body = JSON.parse(res.body)
    assert_equal(2, body['anagrams'].size)

    res = @client.get('/anagrams/Aa.json', 'proper_noun=false')
    assert_equal('200', res.code, "Unexpected response code")

    body = JSON.parse(res.body)
    assert_equal(1, body['anagrams'].size)
  end

  def test_most_anagrams
    @client.post('/words.json', nil, {"words" => ["Aa", "aa"] }) rescue nil

    res = @client.get('/most_anagrams.json')
    assert_equal('200', res.code, "Unexpected response code")

    body = JSON.parse(res.body)
    assert_equal(body['anagrams'][0], ["read", "dear", "dare"])
    assert_equal(body['anagrams'][1], ["Aa", "aa"])
  end

  def test_anagram_group_size
    @client.post('/words.json', nil, {"words" => ["Aa", "aa"] }) rescue nil

    res = @client.get('/anagram_groups.json', 'size=3')
    assert_equal('200', res.code, "Unexpected response code")

    body = JSON.parse(res.body)
    assert_equal(body['anagrams'][0], ["read", "dear", "dare"])
    assert_equal(body['anagrams'][1], nil)
  end
end

require 'test/unit'
require 'rubygems'
require 'activerecord_test_case'
require 'acts_as_fulltextable'

class ActsAsFulltextableTest2 < ActiveRecordTestCase
  fixtures :widgets

  def setup
    FulltextRow.destroy_all
    Widget.find(:all).each {|i| i.create_fulltext_record}
  end

  def test_single_search_result
    results = Widget.find_fulltext('content')
    assert_equal 1, results.size
    assert_equal widgets(:one), results.first
  end

  def test_unindexed_content
    results = Widget.find_fulltext('unfindable')
    assert_equal 0, results.size
  end

  def test_exclusion_of_conditional_content
    results = Widget.find_fulltext('inactive')
    assert_equal 0, results.size
  end

  def test_multiple_search_results
    results = Widget.find_fulltext('widget')
    assert_equal 2, results.size
    assert_send [results, :include?, widgets(:one)]
    assert_send [results, :include?, widgets(:two)]
  end

end

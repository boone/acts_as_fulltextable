require 'activerecord_test_connector'

class ActiveRecordTestCase < Test::Unit::TestCase
  if defined?(ActiveSupport::Testing::SetupAndTeardown)
    include ActiveSupport::Testing::SetupAndTeardown
  end

  if defined?(ActiveRecord::TestFixtures)
    include ActiveRecord::TestFixtures
  end

  self.fixture_path = File.join(File.dirname(__FILE__), '..', 'fixtures')
  self.use_transactional_fixtures = true
  
  # Default so Test::Unit::TestCase doesn't complain
  def test_truth
  end

  protected

    def assert_queries(num = 1)
      $query_count = 0
      yield
    ensure
      assert_equal num, $query_count, "#{$query_count} instead of #{num} queries were executed."
    end

    def assert_no_queries(&block)
      assert_queries(0, &block)
    end

    # for some reason in Ruby 1.9, the test breaks due to a missing "method_name" method
    if RUBY_VERSION >= '1.9'
      define_method 'method_name' do
        'aaf'
      end
    end
end

ActiveRecordTestConnector.setup
abort unless ActiveRecordTestConnector.able_to_connect

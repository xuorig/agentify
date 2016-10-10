require './test/test_helper'

class BucketTest < Minitest::Test
  def setup
    @bucket = Agentify::Bucket.new(max_size: 100)
  end

  def test_test
    skip 'todo'
  end
end

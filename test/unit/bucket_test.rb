require './test/test_helper'

class BucketTest < Minitest::Test
  def setup
    @bucket = Agentify::Bucket.new(max_size: 100)
  end

  def test_consume_returns_data_inside_the_bucket
    @bucket.add(1)
    @bucket.add(2)
    @bucket.add(3)

    assert_equal [1,2,3], @bucket.consume!
  end

  def test_consume_resets_the_bucket_to_empty_array
    @bucket.add(1)
    @bucket.add(2)
    @bucket.add(3)
    @bucket.consume!

    assert_equal [], @bucket.consume!
  end

  def test_consume_does_not_add_if_full
    small_bucket = Agentify::Bucket.new(max_size: 2)
    small_bucket.add(1)
    small_bucket.add(2)
    small_bucket.add(3)

    assert_equal [1,2], small_bucket.consume!
  end
end

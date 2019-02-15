require "test_helper"

class HttpHeaders::UtilsTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::HttpHeaders::Utils::VERSION
  end
end

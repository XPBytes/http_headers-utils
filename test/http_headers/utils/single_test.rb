require 'test_helper'
require 'delegate'

module HttpHeaders
  module Utils
    class SingleTest < Minitest::Test

      class ContentType
        attr_reader :content_type

        def initialize(content_type, parameters:, **_opts)
          self.content_type = content_type
          self.parameters = parameters
        end

        def to_header
          [content_type].concat(parameters.map { |k, v| "#{k}=#{v}" }).compact.reject(&:empty?).join('; ')
        end

        def to_s
          to_header
        end

        def [](index)
          parameters.fetch(index)
        end

        def charset
          parameters.fetch(:charset) { nil }
        end

        private

        attr_writer :content_type
        attr_accessor :parameters
      end

      class TestContentType < DelegateClass(ContentType)

        def initialize(value)
          single = HttpHeaders::Utils::Single.new(value, entry_klazz: ContentType)
          __setobj__ single
        end

        def to_s
          HttpHeaders::Utils::Single.to_header(self)
        end
      end

      def test_it_parses_empty
        TestContentType.new('')
        pass 'did not break'
      end

      def test_it_parses_one
        entry = TestContentType.new('application/json')
        assert_equal 'application/json', entry.to_s
      end

      def test_it_parses_parameters
        entry = TestContentType.new('application/json; foo=bar; charset=utf-8')
        assert_equal 'bar', entry[:foo]
        assert_equal 'utf-8', entry.charset
      end

      def test_it_parses_multiple_lines
        entry = TestContentType.new(['text/plain', 'application/json, text/html; charset=utf-8'])
        assert_equal 'text/html; charset=utf-8', entry.to_s
      end

      def test_it_can_convert_to_a_header
        entry = TestContentType.new(['text/plain', 'application/json, text/html; charset=utf-8'])
        assert_equal 'text/html; charset=utf-8', entry.to_s
      end
    end
  end
end

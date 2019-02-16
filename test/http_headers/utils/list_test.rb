require 'test_helper'
require 'delegate'

module HttpHeaders
  module Utils
    class ListTest < Minitest::Test
      class TestAccept < DelegateClass(Array)

        def initialize(value)
          list = HttpHeaders::Utils::List.new(value, entry_klazz: Entry)
          __setobj__ list
        end

        def to_s
          HttpHeaders::Utils::List.to_header(self)
        end

        class Entry
          attr_reader :media_type, :index

          def initialize(media_type, index:, parameters:)
            self.media_type = media_type
            self.index = index
            self.parameters = parameters
          end

          def q
            parameters.fetch(:q) { 1.0 }.to_f
          end

          def <=>(other)
            quality = other.q <=> q
            return quality unless quality.zero?
            index <=> other.index
          end

          def to_header
            [media_type].concat(parameters.map { |k, v| "#{k}=#{v}" }).compact.reject(&:empty?).join('; ')
          end

          def to_s
            to_header
          end

          def [](index)
            parameters.fetch(index)
          end

          private

          attr_writer :media_type, :index
          attr_accessor :parameters
        end
      end

      def test_it_parses_empty
        TestAccept.new('')
        pass 'did not break'
      end

      def test_it_parses_one
        list = TestAccept.new('application/json')
        assert_equal 1, list.length
        assert_equal 'application/json', list.first.to_s
      end

      def test_it_parses_parameters
        list = TestAccept.new('application/json; foo=bar; q=0.5')
        assert_equal 1, list.length
        assert_equal 'bar', list.first[:foo]
        assert_equal 0.5, list.first.q
      end

      def test_it_parses_multiple_lines
        list = TestAccept.new(['*/*; q=0.1', 'application/json, text/html; q=0.8'])
        assert_equal 3, list.length
        assert_equal 'application/json', list.first.to_s
        assert_equal '*/*; q=0.1', list.last.to_s
        assert_equal 0.8, list[1].q
      end

      def test_it_can_convert_to_a_header
        list = TestAccept.new(['*/*; q=0.1', 'application/json, text/html; q=0.8'])
        assert_equal 'application/json, text/html; q=0.8, */*; q=0.1', list.to_s
      end
    end
  end
end

require 'delegate'

module HttpHeaders
  module Utils

    ##
    # @example Accept values
    #
    #   class Accept < HttpHeaders::Utils::List
    #     def initialize(value)
    #       super value, entry_klazz: Accept::Entry
    #       sort!
    #     end
    #
    #     class Entry
    #       def initialize(media_type, index: parameters:)
    #         ...
    #       end
    #
    #       def q
    #         parameters.fetch(:q) { 1.0 }.to_f
    #       end
    #
    #       def <=>(other)
    #         quality = other.q <=> q
    #         return quality unless quality.zero?
    #         index <=> other.index
    #       end
    #     end
    #   end
    #
    #   Accept.new(['*/*; q=0.1', 'application/json, text/html; q=0.8'])
    #   # => List['application/json', 'text/html', '*/*']
    #
    class List < DelegateClass(Array)

      HEADER_DELIMITER    = ','
      PARAMETER_DELIMITER = ';'

      class << self
        def parse(combined, entry_klazz:)
          Array(combined).map { |line| line.split(HEADER_DELIMITER) }.flatten.each_with_index.map do |entry, index|
            value, *parameters = entry.split(PARAMETER_DELIMITER)
            indexed_parameters = Hash[Array(parameters).map { |p| p.strip.split('=') }].transform_keys!(&:to_sym)
            entry_klazz.new(value, index: index, parameters: indexed_parameters)
          end
        end
      end

      ##
      # Create a new list
      #
      # @param value [String] the header value
      # @param entry_klazz [Class] the class for the list items
      #
      # @see List.parse
      #
      def initialize(value, entry_klazz:)
        super List.parse(value, entry_klazz: entry_klazz)
      end

      def sort!
        __setobj__(__getobj__.sort!)
      end

      def inspect
        map(&:inspect).join(', ')
      end
    end
  end
end

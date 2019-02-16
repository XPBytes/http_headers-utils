module HttpHeaders
  module Utils

    ##
    # @example Accept values
    #
    #   class Accept < DelegateClass(Array)
    #     def initialize(value)
    #       super HttpHeaders::List.new(value, entry_klazz: Accept::Entry)
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
    module List
      HEADER_DELIMITER    = ','
      PARAMETER_DELIMITER = ';'

      module_function

      def parse(combined, entry_klazz:)
        Array(combined).map { |line| line.split(HEADER_DELIMITER) }.flatten.each_with_index.map do |entry, index|
          value, *parameters = entry.strip.split(PARAMETER_DELIMITER)
          indexed_parameters = Hash[Array(parameters).map { |p| p.strip.split('=') }].transform_keys!(&:to_sym)
          entry_klazz.new(value, index: index, parameters: indexed_parameters)
        end
      end

      def new(combined, entry_klazz:)
        result = parse(combined, entry_klazz: entry_klazz)
        entry_klazz.instance_methods(false).include?(:<=>) ? result.sort! : result
      end

      def to_header(list)
        # noinspection RubyBlockToMethodReference
        list.map { |entry| stringify_entry(entry) }
            .join("#{HEADER_DELIMITER} ")
      end

      def stringify_entry(entry)
        return entry.to_header if entry.respond_to?(:to_header)
        return entry.to_s if entry.respond_to?(:to_s)
        entry.inspect
      end
    end
  end
end

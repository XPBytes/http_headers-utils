require 'http_headers/utils/list'

module HttpHeaders
  module Utils
    module Single
      module_function

      def parse(value, entry_klazz:)
        List.new(value, entry_klazz: entry_klazz).last
      end

      def new(*args)
        parse(*args)
      end

      def to_header(single)
        List.stringify_entry(single)
      end

      alias new parse
    end
  end
end

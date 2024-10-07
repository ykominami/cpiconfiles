# frozen_string_literal: true

module Cpiconfiles
  @sizepattern = nil
  class Appenv
    class << self
      def set_dump_file(dump_fname: "",
            dont_use_dump_file: false)
        @dump_file = Dump.new(dump_fname, dont_use_dump_file)
      end
      def dump_file
        @dump_file
      end
    end
  end
end

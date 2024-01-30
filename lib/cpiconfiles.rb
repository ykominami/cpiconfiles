# frozen_string_literal: true

require 'pathname'
require 'loggerx'
require 'thor'
require 'csv'
require 'pp'


require_relative 'cpiconfiles/version'
require_relative 'cpiconfiles/iconfilegroup_array'
require_relative 'cpiconfiles/sizepattern'
require_relative 'cpiconfiles/iconfile'
require_relative 'cpiconfiles/iconlist'
require_relative 'cpiconfiles/iconfilegroup'
require_relative 'cpiconfiles/sizeddir'
require_relative 'cpiconfiles/loggerxcm'

require_relative 'cpiconfiles/google_drive'

require_relative 'cpiconfiles/csvdata'
require_relative 'cpiconfiles/cpiconfx'

=begin
require_relative 'cpiconfiles/iconf'
require_relative 'cpiconfiles/iconf0'
require_relative 'cpiconfiles/iconf1'
require_relative 'cpiconfiles/iconf2'
require_relative 'cpiconfiles/iconf3'
# require_relative 'cpiconfiles/my_counter'
# require_relative 'cpiconfiles/my_cmd'
=end
require_relative 'cpiconfiles/cmd'
# require_relative 'cpiconfiles/command'
require_relative 'cpiconfiles/cli'

module Cpiconfiles
  class Error < StandardError; end
  # Your code goes here...
  class InvalidStringClass < Error; end
  class NotPathnameClassError < Error; end
end

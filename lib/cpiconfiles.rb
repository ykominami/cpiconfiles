# frozen_string_literal: true

require 'pathname'
require 'loggerx'
require 'thor'
require 'csv'

require_relative 'cpiconfiles/version'
require_relative 'cpiconfiles/iconfilegroup_array'
require_relative 'cpiconfiles/sizepattern'
require_relative 'cpiconfiles/iconfile'
require_relative 'cpiconfiles/iconlist'
require_relative 'cpiconfiles/iconfilesubgroup'
require_relative 'cpiconfiles/iconfilegroup'
require_relative 'cpiconfiles/sizeddir'
require_relative 'cpiconfiles/loggerxcm'

require_relative 'cpiconfiles/google_drive'

require_relative 'cpiconfiles/csvdata'
require_relative 'cpiconfiles/cpiconfx'

require_relative 'cpiconfiles/cmd'
require_relative 'cpiconfiles/cli'
require_relative 'cpiconfiles/yamlstore'

module Cpiconfiles
  class Error < StandardError; end
  # Your code goes here...
  class InvalidStringClass < Error; end
  class NotPathnameClassError < Error; end
end

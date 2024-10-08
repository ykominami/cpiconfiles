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
require_relative 'cpiconfiles/iconlist_print'
require_relative 'cpiconfiles/iconfilesubgroup'
require_relative 'cpiconfiles/iconfilegroup'
require_relative 'cpiconfiles/sizeddir'
require_relative 'cpiconfiles/loggerxcm'

require_relative 'cpiconfiles/google_drive'

require_relative 'cpiconfiles/csvdata'

require_relative 'cpiconfiles/cmd'
require_relative 'cpiconfiles/cli'
require_relative 'cpiconfiles/yamlstore'
require_relative 'cpiconfiles/dump'
require_relative 'cpiconfiles/appenv'

module Cpiconfiles
  class Error < StandardError; end
  # Your code goes here...
  class InvalidStringClass < Error; end
  class NotPathnameClassError < Error; end
  class UnspecifiedTopDirError < Error; end
  class InvalidIconlistError < Error; end
  class NotIconfilegroupError < Error; end
  class NotInstanceOfHashError < Error; end
  class NotInstanceOfIconfilegroupError < Error; end
  class NotFoundInRestorehsByIdError < Error; end
  class NotEqualIdError < Error; end
  class DifferentClassError < Error; end
  class NotFoundIconfileError < Error; end
  class NotFoundIconlistError < Error; end
end


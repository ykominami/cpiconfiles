# frozen_string_literal: true

require 'pathname'
require 'loggerx'

require_relative 'cpiconfiles/version'
require_relative 'cpiconfiles/cli'
require_relative 'cpiconfiles/sizepattern'
require_relative 'cpiconfiles/iconfile'
require_relative 'cpiconfiles/iconlist'
require_relative 'cpiconfiles/iconfilegroup'
require_relative 'cpiconfiles/sizeddir'
require_relative 'cpiconfiles/loggerxcm'

module Cpiconfiles
  class Error < StandardError; end
  # Your code goes here...
end

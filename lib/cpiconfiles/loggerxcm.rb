module Cpiconfiles
  class Loggerxcm < Loggerx::Loggerxcm0
    @log_level = nil
    @init_count = 0

    class << self
      def log_init(log_level)
        return unless @log_level.nil?

        @log_level = log_level
        init('log_', 'log.txt', '.', true, log_level) if @init_count.zero?
        @init_count += 1
      end
    end
  end
end

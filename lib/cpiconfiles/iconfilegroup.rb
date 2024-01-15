module Cpiconfiles
  # TODO: class Iconfilegroupを実装する
  class Iconfilegroup
    def initialize(name, parent_pn)
      @name = name
      @parent_pn = parent_pn
      @iconfiles = {}
    end

    def add(name, iconfile)
      @iconfiles[name] = iconfile
    end

    def print
      @iconfiles.map { |key, icf|
        Loggerxcm.debug "#{key} | #{icf.pathn}"
      }
    end
  end
end

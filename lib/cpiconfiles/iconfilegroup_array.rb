module Cpiconfiles
  # TODO: class Iconfilegroupを実装する
  class IconfilegroupArray < Array
    # alias find_original find

    def set_iconfilegroup(iconfilegroup)
      @iconfilegroup = iconfilegroup
      self
    end

    def findx(name, value)
      @iconfilegroup.findx(name, value, self)
    end
  end
end
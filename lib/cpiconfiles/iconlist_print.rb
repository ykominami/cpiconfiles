require "yaml"
require "pathname"

module Cpiconfiles
  class Iconlist
    def print
      @iconfilegroups.map do |key, icfg|
        raise NotInstanceOfIconfilegroupError.new("icfg.class=#{icfg.class}") unless icfg.instance_of?(Cpiconfiles::Iconfilegroup)

        Loggerxcm.debug key
        icfg.print
      end
    end

    def print2
      Loggerxcm.debug "ICONLIST#PRINT2 @iconfilegroups.size=#{@iconfilegroups.size}"

      @iconfilegroups.map do |key, icfg|
        raise NotInstanceOfIconfilegroupError unless icfg.instance_of?(Iconfilegroup)

        Loggerxcm.debug "key=#{key}"
        icfg.print2
      end
    end

    def print_l1
      p "Iconlist#print_l1"
      @iconfilegroups.map do |_key, icfg|
        raise NotInstanceOfIconfilegroupError unless icfg.instance_of?(Iconfilegroup)

        icfg.print_l1
      end
    end

    def print_l1_icon_size
      @iconfilegroups.map do |_key, icfg|
        raise NotInstanceOfIconfilegroupError unless icfg.instance_of?(Iconfilegroup)

        icfg.print_l1_icon_size
      end
    end

    def print_l2
      @iconfilegroups.map do |_key, icfg|
        raise NotInstanceOfIconfilegroupError unless icfg.instance_of?(Iconfilegroup)

        icfg.print_l2
      end
    end

    def show_iconfilegroups
      @iconfilegroups.each do |key, ifg|
        raise NotInstanceOfIconfilegroupError unless ifg.instance_of?(Iconfilegroup)
        ifg.show_iconfiles
      end
    end
  end
end

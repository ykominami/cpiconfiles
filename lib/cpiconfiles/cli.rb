module Cpiconfiles
  class Cli
    def initialize
      log_level = :debug
      #log_level = :info
      Loggerxcm.log_init(log_level)
    end

    def set_vars(top_dir_pn, dump_fname)
      @top_dir_pn = top_dir_pn
      @dump_fname = dump_fname
    end

    def setup
      loaded = false
      iconlist = Iconlist.new(@dump_fname, @top_dir_pn)
      if File.exist?(@dump_fname)
        iconlist.load
        loaded = true
        #  loaded = iconlist.check_files2
        #  iconlist.print_pathns()
      end
      [iconlist, loaded]
    end

    def collect(iconlist)
      Loggerxcm.debug 'Collect'
      iconlist.collect(@top_dir_pn)
    end

    def analyze(iconlist)
      Loggerxcm.debug iconlist.l1_keys
      iconlist.l1_keys.map do |l1_key|
        iconlist.l2_keys(l1_key).map do |l2_key|
          Loggerxcm.debug "#{l1_key}|#{l2_key}"
          xitem = iconlist.pathn_by_keys(l1_key, l2_key)
          next unless xitem.instance_of?(Hash)

          xitem.each do |l3_key, l3_array|
            Loggerxcm.debug "#{l1_key}|#{l2_key}|#{l3_key}"
            l3_array.map do |icf|
              Loggerxcm.debug "1 icf.relative_pathn=#{icf.relative_pathn} icf.icon_size=#{icf.icon_size}"
            end
          end
        end
      end
    end

    def execute
      iconlist, loaded = setup()

      # デバッグのため、強制的に再構築する
      loaded = false

      collect(iconlist) unless loaded

      analyze(iconlist)
      p "cred=#{GoogleDrive.get_credentials}"
      csv_fname = "a.csv"
      iconlist.save_as_csv(csv_fname)

      # exit
      # gd = GoogleDrive.new
      # gd.upload(iconlist.save_as_csv)

      iconlist.dump
    end

    def print
      iconlist, loaded = setup()

      # デバッグのため、強制的に再構築する
      loaded = false

      collect(iconlist) unless loaded

      analyze(iconlist)
      p "cred=#{GoogleDrive.get_credentials}"
      csv_fname = "a.csv"
      iconlist.save_as_csv(csv_fname)

      # exit
      # gd = GoogleDrive.new
      # gd.upload(iconlist.save_as_csv)

      # iconlist.dump
      iconlist.print
      iconlist.print_l1
      iconlist.print_l1_icon_size
      iconlist.print_l2

    end
  end
end

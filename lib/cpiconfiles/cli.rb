module Cpiconfiles
  class Cli
    def initialize
      log_level = :debug
      # log_level = :info
      Loggerxcm.log_init(log_level)
      @sizepat = Sizepattern.new
    end

    def set_vars(top_dir_pn, dump_fname, csv_fname)
      @top_dir_pn = top_dir_pn
      @dump_fname = dump_fname
      @csv_fname = csv_fname
    end

    def setup
      iconlist = Iconlist.new(@dump_fname, @sizepat, @top_dir_pn)
      iconlist.show_iconfilegroups
      if @dump_fname && File.exist?(@dump_fname)
        Loggerxcm.debug '#=== [Cli] Load'
        iconlist.load
      end
      iconlist.show_iconfilegroups
      iconlist
    end

    def collect(iconlist)
      Loggerxcm.debug '#=== [Cli] Collect'
      iconlist.collect(@top_dir_pn)
    end

    def execute
      execute_bpdy
    end

    def execute_body
      iconlist = setup
      iconlist.show_iconfilegroups
      raise unless iconlist
      # デバッグのため、強制的に再構築する
      # loaded = false
      collect(iconlist) unless iconlist.valid?
      # iconlist.show_iconfilegroups

      iconlist.setup_for_iconfiles
      iconlist.analyze
      p "cred=#{GoogleDrive.get_credentials}"

      iconlist.save_as_csv(@csv_fname) if @csv_fname
      iconlist.dump
      iconlist
    end

    def json
      iconlist = execute_body
      iconlist.json
    end

    def yaml
      iconlist = execute_body
      iconlist.save_to_obj(-1)
      Yamlstore.add_iconlist(iconlist)
    end

    def restore(obj, dump_fname, sizepat)
      Yamlstore.restore(obj, dump_fname, @sizepat)
      iconlist = setup
      iconlist.restore()
      iconlist.print2
    end

    def print2
      iconlist = execute_body
      iconlist.print2
    end

    def print
      iconlist = print_prepare
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

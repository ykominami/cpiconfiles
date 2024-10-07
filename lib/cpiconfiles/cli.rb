module Cpiconfiles
  class Cli
    def initialize
      # log_level = :debug
      log_level = :info
      Loggerxcm.log_init(log_level)
      @sizepat = Sizepattern.new
      # Appenv.sizepattern = @sizepat
      @defalut_dump_filename = 'cpiconfiles.dump'

      @top_dir_pn = nil
      @output_fname = ''
      @dump_fname = ''
      @csv_fname = ''

      @dump_load_result = nil
    end

    def set_vars(top_dir_pn: nil, output_fname: '', dump_fname: '',
                 csv_fname: '')
      raise UnspecifiedTopDirError.new( "Cli set_vars top_dir_pn=#{top_dir_pn}" ) if top_dir_pn.nil?
      @top_dir_pn = top_dir_pn
      @output_fname = output_fname
      @dump_fname = dump_fname
      @csv_fname = csv_fname

      Appenv.set_dump_file(dump_fname: @dump_fname)
    end

    def setup
      iconlist = Iconlist.new(@sizepat, @top_dir_pn)
      # Loggerxcm.debug '#=== [Cli] Load'
      # dumpファイルから取り込み
      iconlist.load
      iconlist
    end

    def collect(iconlist)
      Loggerxcm.debug "#=== [Cli] Collect @top_dir_pn=#{@top_dir_pn}"
      iconlist.collect(@top_dir_pn)
    end

    def execute
      execute_body
    end

    def execute_body
      iconlist = setup
      raise InvalidIconlistError.new("Cli execute_body 1") unless iconlist.valid?
      iconlist.move_state

      # iconlist.show_iconfilegroups

      # デバッグのため、強制的に再構築する
      # loaded = false
      collect(iconlist) unless iconlist.valid?
      # iconlist.show_iconfilegroups

      iconlist.setup_for_iconfiles
      iconlist.analyze

      iconlist.save_as_csv(@csv_fname) if !@csv_fname.nil? && @csv_fname.strip.size.positive?
      iconlist.dump
      iconlist
    end

    def json
      iconlist = execute_body
      iconlist.json
    end

    def yaml
      iconlist = execute_body
      store_inst = iconlist.save_to_obj(-1)
      Yamlstore.add_iconlist(iconlist)
    end

    def restore(obj)
      Yamlstore.restore(obj, @sizepat)
      iconlist = setup
      iconlist.restore
      iconlist.print2
    end

    def print2
      iconlist = execute_body
      iconlist.print2
    end

    def print
      iconlist = execute_body
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

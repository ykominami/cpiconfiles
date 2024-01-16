module Cpiconfiles
  class Cli
    def initialize
      # log_level = :debug
      log_level = :info
      Loggerxcm.log_init(log_level)
    end

    def arg_parse(argv)
      top_dir = argv[0]
      dump_fname = argv[1]
      @sizepat = Sizepattern.new

      useage = "useage: #{$0} top_dir dump_file"
      puts argv.size

      if argv.size != 2
        puts useage
        puts '0'
        exit(10)
      end

      if !top_dir.nil? && top_dir.strip.empty?
        puts useage
        puts '1'
        exit(20)
      end

      if !dump_fname.nil? && dump_fname.strip.empty?
        puts useage
        puts '2'
        exit(30)
      end

      @top_dir_pn = Pathname.new(top_dir).expand_path
      @dump_fname = dump_fname
    end

    def get_icon_files(dir_pn, parent_sizeddir = nil)
      icon_files = []
      # Loggerxcm.debug  "dir_pn~#{dir_pn}"
      dir_pn.children.each do |pn|
        # Loggerxcm.debug  "pn=#{pn}"
        if pn.file?
          icf = Iconfile.new(@top_dir_pn, pn, @sizepat, parent_sizeddir)
          next unless icf.valid

          icon_files << icf
        else
          sizeddir = Sizeddir.new(pn, @sizepat)
          sizeddirx = if sizeddir.valid
                        sizeddir
                      else
                        parent_sizeddir
                      end
          icon_files2 = get_icon_files(pn, sizeddirx)
          icon_files += icon_files2
        end
      end
      icon_files
    end

    def execute
      loaded = false
      iconlist = Iconlist.new(@dump_fname)
      if File.exist?(@dump_fname)
        iconlist.load
        #  loaded = iconlist.check_files
        #  iconlist.print_pathns()
      end

      unless loaded
        Loggerxcm.debug 'Search'
        iconfiles = get_icon_files(@top_dir_pn)
        Loggerxcm.debug "iconfiles.size=#{iconfiles.size}"
        iconlist.create_paths(iconfiles)
        # iconlist.check_files
      end

      iconlist.print_pathns2
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
      # exit

      iconlist.save
    end
  end
end

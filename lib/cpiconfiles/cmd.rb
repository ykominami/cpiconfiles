module Cpiconfiles
  class Cmd < Thor
    option :d, banner: '<dump_fname>'
    option :c, banner: '<csv_fname>'
    desc 'cp2 <top_dir>', 'copy icon files'
    def cp2(top_dir)
      @top_dir_pn = Pathname.new(top_dir).expand_path
      @dump_fname = options[:d]
      @csv_fname = options[:c]

      puts "#{top_dir} #{@dump_fname}"
      cli = Cli.new
      cli.set_vars(@top_dir_pn, @dump_fname, @csv_fname)
      #      cli.print
      cli.print2
    end

    option :d, banner: '<dump_fname>'
    option :c, banner: '<csv_fname>'
    desc 'json <top_dir>', 'copy icon files'
    def json(top_dir)
      @top_dir_pn = Pathname.new(top_dir).expand_path
      @dump_fname = options[:d]
      @csv_fname = options[:c]

      cli = Cli.new
      cli.set_vars(@top_dir_pn, @dump_fname, @csv_fname)
      #
      File.write("a.json" , cli.json) 
    end


    option :d, banner: '<dump_fname>'
    option :c, banner: '<csv_fname>'
    desc 'fjson <top_dir>', 'copy icon files'
    def fjson(top_dir)
      @top_dir_pn = Pathname.new(top_dir).expand_path
      @dump_fname = options[:d]
      @csv_fname = options[:c]

      # cli = Cli.new
      # cli.set_vars(@top_dir_pn, @dump_fname, @csv_fname)
      #
      content = File.read("a.json")
      obj = JSON.parse(content)
      p obj
    end

    option :d, banner: '<dump_fname>'
    option :y, banner: '<yaml_fname>'
    desc 'yaml <top_dir>', 'copy icon files'
    def yaml(top_dir)
      @top_dir_pn = Pathname.new(top_dir).expand_path
      @dump_fname = options[:d]
      @yaml_fname = options[:y]

      cli = Cli.new
      cli.set_vars(@top_dir_pn, @dump_fname, @csv_fname)
      #
      cli.yaml
      Yamlstore.save(@yaml_fname)
    end

    option :d, banner: '<dump_fname>'
    option :y, banner: '<yaml_fname>'
    desc 'fyaml <top_dir>', 'copy icon files'
    def fyaml(top_dir)
      @top_dir_pn = Pathname.new(top_dir).expand_path
      @dump_fname = options[:d]
      @yaml_fname = options[:y]

      @sizepat = Sizepattern.new
      # cli = Cli.new
      # cli.set_vars(@top_dir_pn, @dump_fname, @csv_fname)
      #
      content = File.read(@yaml_fname)
      # obj = Yamlstore.load(@yaml_fname, @dump_fname, sizepat)
      obj = Yamlstore.load(@yaml_fname)
      cli = Cli.new
      # cli.restore(obj, @dump_fnmae, @sizepat)
      Yamlstore.loadx(obj)
      Yamlstore.restorex(obj, @dump_fnmae, @sizepatj)
    end

    desc 'csv <csv_file>', 'from csv file'
    def csv0(csv_file)
      csv_class = Struct.new('Csv', :kind, :icon_size, :category, :base, :path)
#      csv_class = Struct.new('Csv', :kind, :icon_size, :base, :path)

      csv_pn = Pathname.new(csv_file).expand_path

      data = CSV.read(csv_pn)
      rows = data.map { |row| csv_class.new(*row) }
      csvdata = Csvdata.new(*rows)
      csvdata.print2
    end
  end
end

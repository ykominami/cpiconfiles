module Cpiconfiles
  class Cmd < Thor
    class << self
      def exit_on_failure?
        true
      end
    end

    #TODO: コピー機能の実装 
    # 指定ファイル群をコピー
    option :d, banner: '<dump_fname>'
    option :dont_use_dump_file, aliases: "-x", default: false, type: :boolean, banner: '-x'
    option :o, banner: '<output_fname>'
    option :c, banner: '<csv_fname>'
    desc 'cp2 <top_dir>', 'copy icon files'
    def cp2(top_dir)
      @top_dir_pn = Pathname.new(top_dir).expand_path
      @dump_fname = options[:d]
      @output_fname = options[:o]
      # 指定されなければ値はnil
      # 指定されていれば、csvファイルに出力
      @csv_fname = options[:c]

      cli = Cli.new
      cli.set_vars(top_dir: @top_dir_pn, dump_fname: @dump_fname, 
                  output_fname: @output_fname, csv_fname: @csv_fname)
      #      cli.print
      cli.print2
    end

    desc 'yaml', 'create a list of all icon files in the subdirectories of a specified directory'
    option :o, required: true, desc: 'output_filename'
    option :d, required: false, desc: 'dump_filename'
    option :c, required: false, desc: 'output_fname'
    option :adont, aliases: "-x", default: false, type: :boolean, desc: 'dont use dump file'
    def yaml(top_dir)
      @top_dir_pn = Pathname.new(top_dir).expand_path
      @dump_fname = options[:d] ? options[:d] : ""
      @output_fname = options[:o]
      @csv_fname = options[:c]
      @dont_use_dump_file = options[:x]
      @adont= options[:adont]
      Appenv.set_dump_file(dump_fname: @dump_fname,
               dont_use_dump_file: @adont)
      cli = Cli.new
      cli.set_vars(top_dir_pn: @top_dir_pn, csv_fname: @csv_fname)
      #
      cli.yaml
      Yamlstore.save(@output_fname)
    end

    desc 'fyaml', 'crate a list of icon files from a specifed yaml file'
    option :o, required: true, desc: 'output_filename'
    def fyaml()
      @output_fname = options[:o]

      obj = Yamlstore.load(@output_fname)
      Yamlstore.loadx(obj)
      Yamlstore.restorex
    end

    desc 'csv', 'crate a list of icon files from a csv file'
    option :i, required: true, desc: 'output_filename'
    def csv0(csv_file)
      csv_class = Struct.new('Csv', :kind, :icon_size, :category, :base, :path)

      csv_pn = Pathname.new(csv_file).expand_path

      data = CSV.read(csv_pn.to_s)
      rows = data.map { |row| csv_class.new(*row) }
      csvdata = Csvdata.new(*rows)
      csvdata.print2
    end

    # 指定ディレクトリ下のアイコンファイルの一覧取得(JSONファイルに出力)
    desc 'json', 'create a list of all icon files in the subdirectories of a specified directory'
    option :o, required: true, desc: 'output_filename'
    option :d, required: false, desc: 'dump_filename'
    # option :c, required: false, desc: 'output_fname'
    option :adont, aliases: "-x", default: false, type: :boolean, desc: 'dont use dump file'
    # option :d, banner: '<dump_fname>'
    # option :o, banner: '<output_fname>'
    # option :c, banner: '<csv_fname>'
    option :dont_use_dump_file, aliases: "-x", type: :boolean, banner: ''
    desc 'json <top_dir>', 'copy icon files'
    def json(top_dir)
      p "top_dir=#{top_dir}"

      @top_dir_pn = Pathname.new(top_dir).expand_path
      @output_fname = options[:o]
      @dump_fname = options[:d]

      cli = Cli.new
      cli.set_vars(top_dir_pn: @top_dir_pn, dump_fname: @dump_fname)
      #
      File.write(@dump_fname , cli.json) unless @dump_fname.nil?
    end

    # jsonコマンドの出力を解析(JSONファイルを入力)
    option :d, banner: '<dump_fname>'
    desc 'fjson <top_dir>', 'copy icon files'
    def fjson()
      @dump_fname = options[:d]
      # 指定されなければ値はnil
      # 指定されていれば、csvファイルに出力
      # @csv_fname = options[:c]

      content = File.read(@dump_fname)
      obj = JSON.parse(content)
    end
  end
end

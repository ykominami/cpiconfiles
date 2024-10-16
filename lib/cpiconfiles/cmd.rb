require 'fileutils'
require 'date'

module Cpiconfiles
  class Cmd < Thor
    class << self
      def exit_on_failure?
        true
      end
    end

    option :o, required: false, desc: 'output_filename'
    desc 'csv_upload <top_dir>', 'crate a list of icon files from a csv file'
    def csv_upload(top_dir)
      @top_dir_pn = Pathname.new(top_dir).expand_path
      @output_fname = options[:o]
      @output_fname = "pciconfile.csv"
      @csv_file_pn = Pathname.new(@output_fname).expand_path

      fname_in_gd_base = @csv_file_pn.basename(".*").to_s
      dtstr=Time.now.strftime('%Y%m%d-%H%M%S')
      fname_in_gd = "#{fname_in_gd_base}-#{dtstr}"

      cli = Cli.new
      cli.set_vars(top_dir_pn: @top_dir_pn, csv_pn: @csv_file_pn)
      cli.csv

      # gd = GoogleDrive.new
      gd = GDrive.new
      gd.upload(@csv_file_pn.to_s, fname_in_gd)
    end

    option :o, required: true, desc: 'output_filename'
    desc 'csv <top_dir>', 'crate a list of icon files from a csv file'
    def csv(top_dir)
      @top_dir_pn = Pathname.new(top_dir).expand_path
      @output_fname = options[:o]
p "@output_fname=#{@output_fname}"
      @csv_file_pn = Pathname.new(@output_fname).expand_path
p "@csv_file_pn=#{@csv_file_pn}"

      cli = Cli.new
      cli.set_vars(top_dir_pn: @top_dir_pn, csv_pn: @csv_file_pn)
      cli.csv
    end

    # Google Driveにcsvファイルをアップロード
    option :i, required: false, desc: 'input_filename'
    desc 'csv <top_dir>', 'crate a list of icon files from a csv file'
    def csvi(top_dir)
      @top_dir_pn = Pathname.new(top_dir).expand_path

      @csv_file_pn = nil
      @input_fname = options[:i]
      @output_fname = options[:o]

      @csv_file_pn = Pathname.new(@input_fname).expand_path if @input_fname.nil? || @input_fname.strip.empty?
      if @csv_file_pn
        csv_class = Struct.new('Csv', :kind, :icon_size, :category, :base, :path)

        csv_pn = Pathname.new(csv_file).expand_path
  
        data = CSV.read(csv_pn.to_s)
        rows = data.map { |row| csv_class.new(*row) }
        csvdata = Csvdata.new(*rows)
        csvdata.print2
      else
        @csv_file_pn = Pathname.new(@output_fname).expand_path if @output_fname.nil? || @output_fname.strip.empty?
      end

 
      # gd = GoogleDrive.new
      # gd.upload(iconlist.save_as_csv)

    end

    #TODO: コピー機能の実装 
    # 指定ファイル群をコピー
    option :d, banner: '<dump_fname>'
    option :dont_use_dump_file, aliases: "-x", default: false, type: :boolean, banner: '-x'
    option :o, required: false, desc: 'output_dir'
    desc 'cp2 <top_dir>', 'copy icon files'
    def cp2(top_dir)
      @top_dir_pn = Pathname.new(top_dir).expand_path
      @dump_fname = options[:d]
      @output_dir = options[:o]
      # 指定されなければ値はnil
      # 指定されていれば、csvファイルに出力
      if @output_dir.nil? || @output_dir.strip.empty?
        @output_dir = "./_output"
      end
      @output_dir_pn = Pathname.new(@output_dir).expand_path
      if @output_dir_pn.exist?
        FileUtils.rm_r(Dir.glob(@output_dir_pn.to_s + "/*")) 
      else
        @output_dir_pn.mkpath
      end
      cli = Cli.new
      cli.set_vars(top_dir_pn: @top_dir_pn, csv_fname: @csv_fname)
      cli.copy_to(@output_dir_pn)

    end

    desc 'yaml <top_dir>', 'create a list of all icon files in the subdirectories of a specified directory'
    option :o, required: true, desc: 'output_filename'
    option :d, required: false, desc: 'dump_filename'
    option :c, required: false, desc: 'csv_fname'
    option :adont, aliases: "-x", default: false, type: :boolean, desc: 'dont use dump file'
    def yaml(top_dir)
      @top_dir_pn = Pathname.new(top_dir).expand_path
      @csv_fname = options[:c]

      @dump_fname = options[:d] ? options[:d] : ""
      @output_fname = options[:o]
      @dont_use_dump_file = options[:x]
      @adont= options[:adont]
      Appenv.set_dump_file(dump_fname: @dump_fname,
               dont_use_dump_file: @adont)
      cli = Cli.new(@csv_fname)
	  csv_pn = Pathname.new(@csv_fname)
      cli.set_vars(top_dir_pn: @top_dir_pn, csv_pn: csv_pn)
      #
      cli.yaml
      Yamlstore.save(@output_fname)
    end

    desc 'fyaml', 'crate a list of icon files from a specifed yaml file'
    option :o, required: true, desc: 'output_filename'
    def fyaml()
      @csv_fname = options[:c]
      @output_fname = options[:o]

      obj = Yamlstore.load(@output_fname)
      Yamlstore.loadx(obj)
      Yamlstore.restorex
    end

    # 指定ディレクトリ下のアイコンファイルの一覧取得(JSONファイルに出力)
    desc 'json', 'create a list of all icon files in the subdirectories of a specified directory'
    option :o, required: true, desc: 'output_filename'
    option :d, required: false, desc: 'dump_filename'
    option :adont, aliases: "-x", default: false, type: :boolean, desc: 'dont use dump file'
    desc 'json <top_dir>', 'copy icon files'
    def json(top_dir)
      @top_dir_pn = Pathname.new(top_dir).expand_path
      @output_fname = options[:o]
      @dump_fname = options[:d]
      @dont_use_dump_file = options[:x]
      @adont= options[:adont]
      Appenv.set_dump_file(dump_fname: @dump_fname,
               dont_use_dump_file: @adont)

      cli = Cli.new
      cli.set_vars(top_dir_pn: @top_dir_pn)
      #
      File.write(@output_fname , cli.json)
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

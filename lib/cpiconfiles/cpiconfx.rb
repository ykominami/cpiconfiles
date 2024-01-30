module Cpiconfiles
  class Cpiconfx < Thor
    # number will be available as attr_accessor
    option :d, banner: '<dump_fname>'
    option :t, banner: '<branch>'
    desc 'cpiconfiles <top_dir>', 'copy icon files'
    def cp(top_dir)
      @top_dir_pn = Pathname.new(top_dir).expand_path
      @dump_fname = options[:d]

      puts "#{top_dir} #{@dump_fname}"
      cli = Cli.new
      cli.set_vars(@top_dir_pn, @dump_fname)
      cli.execute
    end

    desc 'csv <csv_file>', 'from csv file'
    def csv(csv_file)
      csv_class = Struct.new('Csv', :kind, :icon_size, :category, :base, :path)

      csv_pn = Pathname.new(csv_file).expand_path
      data = CSV.read(csv_pn)
      rows = data.map { |row| csv_class.new(*row) }
      csvdata = Csvdata.new(*rows)
      p csvdata.l1
      p csvdata.l2
      csvdata.print_l1
      csvdata.print_l1_icon_size
      csvdata.print_l2
    end
  end
end

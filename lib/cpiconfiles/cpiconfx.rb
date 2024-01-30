module Cpiconfiles
  class Cpiconfx < Thor
    # number will be available as attr_accessor
    option :d, :banner => "<dump_fname>"
    option :t, :banner => "<branch>"
    desc "cpiconfiles <top_dir>", "copy icon files"
    def cp(top_dir)
      @top_dir_pn = Pathname.new(top_dir).expand_path
      @dump_fname = options[:d]

      puts "#{top_dir} #{@dump_fname}"
      cli = Cli.new
      cli.set_vars(@top_dir_pn, @dump_fname)
      cli.execute
    end

    option :d, :banner => "<dump_fname>"
    desc "cp2 <top_dir>", "copy icon files"
    def cp2(top_dir)
      @top_dir_pn = Pathname.new(top_dir).expand_path
      @dump_fname = options[:d]

      puts "#{top_dir} #{@dump_fname}"
      cli = Cli.new
      cli.set_vars(@top_dir_pn, @dump_fname)
      cli.print
    end

    desc "csv <csv_file>", "from csv file"
    def csv(csv_file)
      csv_class = Struct.new("Csv", :kind, :icon_size, :category, :base, :path)

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

    desc "csv0 <csv_file>", "from csv file"

    def csv0(csv_file)
      csv_class = Struct.new("Csv", :kind, :icon_size, :category, :basename, :path)

      csv_pn = Pathname.new(csv_file).expand_path
      data = CSV.read(csv_pn)
      csv = data.map { |row| csv_class.new(*row) }
      va = {}
      v = {}
      csv.each do |row|
        v[row.kind] ||= {}
        v[row.kind][row.category] ||= {}
        v[row.kind][row.category][row.base] ||= {}
        v[row.kind][row.category][row.base][row.icon_size] ||= []
        v[row.kind][row.category][row.base][row.icon_size] << row
      end

      v.each do |kind, v2|
        # p "# #{k2}"
        ret = v2
        ret.each do |category, hash3|
          hash3.keys.each do |base|
            # p kx
            kx = base
            if kx =~ /^(.+)\-(.+)\-(.+)$/
              kx1 = $1
              kx2 = $2
              kx3 = $3
              va[kx1] ||= {}
              va[kx1][kx3] ||= []
              va[kx1][kx3] += hash3[kx].values
              # p kx1
              # p kx3
              #
            elsif kx =~ /^(.+)\-(.+)x(.+)$/
              # not match
              kx1 = $1
              kx2 = $2
              kx3 = $3
              va[kx1] ||= []
              va[kx1] += hash3[kx].values
              # p kx1
              #
            elsif kx =~ /^(.+)_(.+)x(.+)$/
              kx1 = $1
              kx2 = $2
              kx3 = $3
              va[kx1] ||= []
              va[kx1] += hash3[kx].values
              # p kx
              #
            elsif kx =~ /^(.+)\s+(.+)x(.+)$/
              # not match
              kx1 = $1
              kx2 = $2
              kx3 = $3
              kx1 = "#{kx1} "
              va[kx1] ||= []
              va[kx1] += hash3[kx].values
              # p kx1
              # p kx
              #
            else
              kx1 = kx
              va[kx1] ||= []
              va[kx1] += hash3[kx].values
              # p kx1
            end
          end
        end
      end
      va.each do |k2, v2|
        # p k2.class
        rails if k2.instance_of?(Hash)

        if v2.instance_of?(Array)
          if v2.size > 10
            p "#{k2} #{v2.size}"
            if v2.size > 10
              p v2
              p "===="
            end
          end
        else
          v2.each do |k3, v3|
            if v3.nil?
              p "#{k2}"
              p k3
              p "===="
            else
              if v3.size > 10
                p "#{k2} #{k3} #{v3.size}"

                vb = {}
                v3.each do |icf|
                  # p icf.basename
                  icf.flatten.map { |x|
                    p x.base
                    p x.category
                    p x.path
                    p "===="
                  }
                end
              end
            end
          end
        end
      end
    end

    desc "A", "b"

    def a
      csv.map { |row|
        v_all[row.kind] ||= {}
        v_all[row.kind][:all] ||= []
        v_all[row.kind][:all] << row
        v_all[row.kind][row.category] ||= {}
        v_all[row.kind][row.category][:all] ||= []
        v_all[row.kind][row.category][:all] << row
        v_all[row.kind][row.category][row.base] ||= {}
        v_all[row.kind][row.category][row.base][:all] = []
        v_all[row.kind][row.category][row.base][:all] << row
        v_all[row.kind][row.category][row.base][row.icon_size] ||= []
        v_all[row.kind][row.category][row.base][row.icon_size] << row
      }
    end
  end
end

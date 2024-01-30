module Cpiconfiles
  class Cmd < Thor
    desc "foo2", "Prints foo"
    def foo2
      puts "foo2"
    end
    # register(class_name, subcommand_alias, usage_list_string, description_string)
=begin
    register(Iconf,  "iconf",  "iconf-usage",  "copy icon files 2")
    register(Iconf0, "iconf0", "iconf0-usage", "copy icon files 2")
    register(Iconf1, "iconf1", "iconf1-usage", "copy icon files 2")
    register(Iconf2, "iconf2", "iconf2-usage", "copy icon files 2")
    register(Iconf3, "iconf3", "iconf3-usage", "copy icon files 3")
    register(Cpiconfx, "cpiconfx", "cpiconfx-usage", "copy icon files")
=end

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
  end
end

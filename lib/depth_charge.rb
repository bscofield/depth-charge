$:.unshift File.dirname(__FILE__)

module DepthCharge
  USER_HOME = File.expand_path('~')

  class << self
    def gem_list(scope = 'local')
      process_gem_list(`gem list --#{scope} --no-verbose`, scope)
    end

    def process_gem_list(raw_gem_list, scope = 'remote')
      gems = raw_gem_list.split(/\n/).select {|g| g =~ / \(/}
      gems.map! {|g| g.sub(/\s+.+$/, '')}
    end

    def local_gems
      gem_list
    end

    def remote_gems
      gems = []
      if File.exists?(File.join(USER_HOME, '.remote_gemlist'))
        File.open(File.join(USER_HOME, '.remote_gemlist'), 'r') do |file|
          gems = file.readlines.map {|l| l.chomp}
        end
      else
        puts "Creating remote gem list cache (this may take awhile)"
        gems = gem_list('remote')
        File.open(File.join(USER_HOME, '.remote_gemlist'), 'wb+') do |file|
          file.puts gems.join("\n")
        end
      end
      gems
    end

    def find_requirements(root)
      root ||= File.dirname(__FILE__) + "/.."
      requirements = {}

      Dir.chdir(root)
      Dir['**/*.rb'].each do |path|
        next if path =~ /^vendor\/rails/
        File.open( path ) do |f|
          f.grep( /^(require|gem)/ ) do |line|
            required = line.scan(/('|")(.+?)('|")/).flatten[1]
            unless [/File/, /\*/, /\</, /#/, /\.{2}/, /^\//].detect {|pattern| required =~ pattern}
              requirements[required] ||= []
              requirements[required] << path
            end
          end
        end
      end

      installed_gems   = local_gems
      all_gems         = remote_gems
      uninstalled_gems = all_gems - installed_gems

      installed   = {}
      uninstalled = {}
      other       = {}
      requirements.keys.sort.each do |k|
        if installed_gems.include?(k)
          installed[k]   = requirements[k] 
        elsif uninstalled_gems.include?(k)
          uninstalled[k] = requirements[k] 
        else
          other[k] = requirements[k]
        end
      end
      
      return installed, uninstalled, other
    end

    def display(hash, header, show_files = true)
      unless hash.empty?
        puts "\n#{header}\n#{'='*header.length}"
        hash.keys.sort.each do |k|
          puts "#{k}"
          puts "  #{hash[k].join("\n  ")}\n" if show_files
        end
      end
    end

    def run(path)
      installed, uninstalled, other = find_requirements(path)

      display(installed, 'INSTALLED GEMS', false)
      display(uninstalled, 'UNINSTALLED GEMS')
      display(other, 'OTHER REQUIREMENTS')
    end
  end
end

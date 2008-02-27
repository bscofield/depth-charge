$:.unshift File.dirname(__FILE__)

module DepthCharge
  def self.find_requirements(root)
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
    
    requirements
  end
  
  def self.run(path)
    requirements = find_requirements(path)
    requirements.keys.map.sort.each do |k|
      puts "\n#{k}"
      puts "  #{requirements[k].join("\n  ")}"
    end
  end
end
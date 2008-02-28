namespace :dc do
  desc 'Check project for dependencies'
  task :check do
    DepthCharge.run(File.expand_path('.'))
  end

  namespace :rails do
    task :load_rails do
      if (File.exists?(RAILS_ROOT) && File.exists?(File.join(RAILS_ROOT, 'app')))
        require "#{RAILS_ROOT}/config/boot"
        require "#{RAILS_ROOT}/config/environment"
      end    
    end

    desc 'Check Rails project for dependencies'
    task :check => :load_rails do
      DepthCharge.run(RAILS_ROOT)
    end
  end
end
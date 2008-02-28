namespace :dc do
  desc 'Check project for dependencies'
  task :check do
    DepthCharge.run(File.expand_path('.'))
  end

  namespace :rails do
    desc 'Check Rails project for dependencies'
    task :check do
      DepthCharge.run(RAILS_ROOT)
    end
  end
end
require 'depth_charge'

desc 'Check project for dependencies'
namespace :depth_charge do
  task :check => :ruby_env do
    DepthCharge.run(RAILS_ROOT)
  end
end
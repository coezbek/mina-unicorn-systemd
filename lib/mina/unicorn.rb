require "mina/unicorn/version"

#
# The following tasks are for generating and setting up the systemd service which runs Unicorn
#
namespace :unicorn do
  
  set :unicorn_service_name,        -> { "unicorn-#{fetch(:application_name)}.service" }
  set :unicorn_systemd_config_path, -> { "/etc/systemd/system/#{fetch :unicorn_service_name}" }
  
  set :nginx_socket_path,           -> { "#{fetch(:shared_path)}/unicorn.sock" }
  
  desc "Generate Unicorn systemd service template in the local repo to customize it"
  task :generate do
    run :local do
      
      target_path = File.expand_path("./config/deploy/templates/unicorn.service.erb")
      source_path = File.expand_path("../templates/unicorn.service.erb", __FILE__)
      
      if File.exist? target_path
        error! %(Unicorn service template already exists; please rm to continue: #{target_path})
      else
        command %(mkdir -p config/deploy/templates)
        command %(cp #{source_path} #{target_path})
      end
            
    end
  end
  
  desc "Setup Unicorn systemd service on the remote server"
  task :setup do
  
    elevate
  
    comment %(Check for systemd on remote server)    
    command %([[ `systemctl` =~ -\.mount ]] || { echo 'Systemd not found, but mina-unicorn_systemd needs it.'; exit 1; }) # From https://unix.stackexchange.com/a/164092
    
    target_path = fetch :unicorn_systemd_config_path

    comment %(Installing unicorn systemd config file to #{target_path})
    command %(echo '#{erb template_path}' > #{target_path})

    comment %(Reloading systemd configuration)
    command %(systemctl daemon-reload)
    
  end
  
  desc "Get the status of the Unicorn systemd service on the remote server"
  task :status do
    command %(systemctl status #{fetch :unicorn_service_name})
  end
  
  desc "Start the Unicorn systemd service on the remote server"
  task :start do
    elevate
    # Start the service and if it fails print the error information 
    # command %(stty $(stty size | sed 's/ / cols /;s/^/rows /'))
    command %((systemctl start #{fetch :unicorn_service_name} && systemctl status #{fetch :unicorn_service_name}) || journalctl --no-pager _SYSTEMD_INVOCATION_ID=`systemctl show -p InvocationID --value #{fetch :unicorn_service_name}`)
  end
  
  desc "Stop the Unicorn systemd service on the remote server"
  task :stop do
    elevate
    command %((systemctl stop #{fetch :unicorn_service_name} && systemctl status #{fetch :unicorn_service_name}) || journalctl --no-pager _SYSTEMD_INVOCATION_ID=`systemctl show -p InvocationID --value #{fetch :unicorn_service_name}`)
  end
  
  desc "Restart the Unicorn systemd service on the remote server"
  task :restart do
    elevate
    command %((systemctl restart #{fetch :unicorn_service_name} && systemctl status #{fetch :unicorn_service_name}) || journalctl --no-pager _SYSTEMD_INVOCATION_ID=`systemctl show -p InvocationID --value #{fetch :unicorn_service_name}`)
  end 
  
  # Returns the path to the template to use. Depending on whether the internal template was customized.
  def template_path
  
    custom_path = File.expand_path("./config/deploy/templates/unicorn.service.erb")
    original_path = File.expand_path("../templates/unicorn.service.erb", __FILE__)
    
    File.exist?(custom_path) ? custom_path : original_path
  end
  
  def elevate 
  
    user = fetch(:user)
    setup_user = fetch(:setup_user, user)
    if setup_user != user
      comment %{Switching to setup_user (#{setup_user})}
      set :user, setup_user
    end
  
  end
  
  desc "Print Unicorn systemd service config expanded from the local template"
  task :print do
    run :local do
      command %(echo '#{erb template_path}')
    end
  end

  desc "Print current Unicorn systemd service config from remote"
  task :print_remote do
    unicorn_systemd_config_path = fetch :unicorn_systemd_config_path
    command %(cat #{unicorn_systemd_config_path})
  end

end

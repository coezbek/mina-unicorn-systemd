# mina-unicorn_systemd

Gem extension for mina-deploy to enable easy setup and deployment of unicorn application server managed via systemd.

## Assumptions

This gem assumes that you

* Are on a Linux system with systemd in /etc/systemd/
* Are using RVM to manage your Ruby version
* That the setup task has sudoer or root permissions or that you are running with execution_mode :system and are entering passwords. If your regular user does not have sudo, then you can set the `setup_user` to the name of a user who does.

## Basic installation instructions

1. Add the following to your Gemfile and make sure that unicorn is available in production environment

```
group :production do
  gem 'unicorn'
end

group :development do  
  gem 'mina-unicorn_systemd', require: false # not necessary to load this when running rails
end
```

2. Change your `deploy.rb` to include `'mina/unicorn.rb'`. Make sure to add after `nginx`

```
require 'mina/nginx'
require 'mina/unicorn'
```

3. Manually run `'mina unicorn:setup'` or invoke from your own setup task to enable all one time tasks.

4. Once you are ready to enable unicorn run `'mina unicorn:enable'` to enable the systemd service (persists across reboots).

5. To manually restart unicorn after a deploy use `'mina unicorn:restart'`.

## Customization

To change the unicorn systemd service template and/or the `unicorn_conf.rb`, run `'mina unicorn:generate'`.

By default `mina-unicorn_systemd` is running unicorn as a user service (`systemd --user`), but the unicorn service template also includes settings for running as a system service. To enable this, add `set :unicorn_system_or_user, 'system'` to the top of your `deploy.rb`.

## Todos

* [ ] [Zero-downtime deployments](https://gist.github.com/c4nc/536a261a496e59033fd4b1ea450e8258)

## Contributing

1. Fork it ( http://github.com/coezbek/mina-unicorn_systemd/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Change gemfile to refer to your local version (`gem 'mina-unicorn_systemd', path: <your path>`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

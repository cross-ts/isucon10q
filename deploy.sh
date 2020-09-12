#!/bin/bash -ex
selfsum="$(openssl dgst -sha256 "$0")"
#export PATH=/home/isucon/local/ruby/bin:$PATH
#
cd ~/git/
git pull --rebase
if [ "_${selfsum}" != "_$(openssl dgst -sha256 "$0")" ]; then
  exec $0
fi

sudo cp ~/git/systemd/* /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl restart isuumo.ruby.service

sudo cp ~/git/nginx/sites-available/isuumo.conf /etc/nginx/sites-available/isuumo.conf

sudo nginx -t
sudo nginx -s reload || :

sudo cp ~/git/mysql/conf.d/mysql.cnf /etc/mysql/conf.d/mysql.cnf
sudo systemctl restart mysql

(
  cd ~/git/isuumo/webapp/ruby
  source ~/env.secret.sh
  source ~/git/env.sh
  export RACK_ENV=production
  # TODO: 対応する
  # export NEW_RELIC_LICENSE_KEY
  # bundle exec newrelic deployment -r "$(git rev-parse HEAD)"
) || :

sudo bash -c 'cp /var/log/nginx/access.log /var/log/nginx/access.log.$(date +%s) && echo > /var/log/nginx/access.log; echo > /tmp/isu-query.log; echo > /tmp/isu-rack.log; echo > /tmp/isu-params.log; echo > /var/lib/mysql/mysql-slow.log; chown isucon:isucon /tmp/isu*.log'

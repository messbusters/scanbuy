#!/usr/bin/env ruby

##
# Deploy the current application
#
# @author Emy <emy@messbusters.org>
##

require 'json'

ROOT = File.expand_path("..", File.dirname(__FILE__))

payload = JSON.parse(ARGV.join(' '))

# Update from git
puts "Updating from git"
`git reset --hard HEAD`
`git checkout -q #{ENV['branch_name']}`
`git pull -q origin #{ENV['branch_name']}`
`chown -R app:app .`
`mkdir tmp`

# Check for new gems
payload["commits"].each do |com|
    if com["modified"].include? 'Gemfile'
        puts "Updating gems"
        `gem install bundler --pre`
        `bundle install`
    end
end

# Restart
puts "Restarting"
`cd predict && pip install -r requirements.txt`
`cd .. && php composer.phar install`
`cp "#{ROOT}/deploy/webapp.conf" /etc/nginx/sites-enabled/webapp.conf`
`sv reload nginx`
puts "Done!"

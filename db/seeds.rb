# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# Environment variables (ENV['...']) can be set in the file config/application.yml.
# See http://railsapps.github.io/rails-environment-variables.html
puts 'Roles'
Role.find_or_create_by_name('administrator')
Role.find_or_create_by_name('artist')

puts 'Users'
User.find_or_create_by_name('Alex Ebert') {|u| u.role = Role.find_by_name('artist')}

puts "Assets"

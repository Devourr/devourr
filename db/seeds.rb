# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create!(name: ENV['DEVELOPER_NAME'], user_name: ENV['DEVELOPER_USER_NAME'], email: ENV['DEVELOPER_EMAIL'], password: 'password', confirmed_at: DateTime.now)

# examples of usernames I don't want people to pick when creating accounts
# problems with routing, offensive, reserved
%w(admin home user discover explore notifications butthead fuck shaq guyfieri).map do |w|
  BlockedUserName.create!(user_name: w)
end

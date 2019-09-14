# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
User.create!(name:  "植野 裕樹",
             email: "yuki@gmail.com",
             password:              "password",
             password_confirmation: "password",
             sex_kbn: "1",
             age: 25,
             area_kbn: "13")

# 男性ユーザー
a = 0
30.times do |n|
  a = n+1
  name  = "test#{n+1000}"
  email = "test#{n+1000}@gmail.com"
  password = "password"
  sex_kbn = "1"
  age = 20
  area_kbn = "#{a}"
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password,
               sex_kbn: sex_kbn,
               age: age,
               area_kbn: area_kbn)
end

# 女性ユーザー
b = 0
30.times do |n|
  b = n+1
  name  = "test#{n+2000}"
  email = "test#{n+2000}@gmail.com"
  password = "password"
  sex_kbn = "2"
  age = 25
  area_kbn = "#{b}"
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password,
               sex_kbn: sex_kbn,
               age: age,
               area_kbn: area_kbn)
end

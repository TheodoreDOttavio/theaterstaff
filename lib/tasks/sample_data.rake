namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    User.create!(name: "Ted",
                 email: "teddottavio@yahoo.com",
                 password: "foobar",
                 password_confirmation: "foobar",
                 admin: true)
    #only the first user has admin privilages, the rest default to false
    99.times do |n|
      name  = Faker::Name.name
      email = "example-#{n+1}@railstutorial.org"
      password  = "password"
      User.create!(name: name,
                   email: email,
                   password: password,
                   password_confirmation: password)
    end
  end
end
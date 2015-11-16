# All times are stored in UTC, GMT00, no time zone!
#  Change local time to GMT 0 for views and data comparison

#This file will load Shows and events that may not represent the current real world environment

# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#  or just use rake db:reset ...

puts "-- Begining seed.rb script"

require 'csv'

    @datamodels = ["Performance",
      "Cabinet",
      "Available",
      "Theater",
      "Product",
      "Distributed"]
      #,"Distributed" commented out for Heroku's 10k datalimit

    @datamodels.each_with_index do |m,i|
      tempfile = Rails.root.join('db',m + '.csv')

      if File.exist?(tempfile) then
        puts "-- loading " + tempfile.to_s

        myfile = File.open(tempfile)
        #Heroku needs to use #{RAILS_ROOT}/tmp/myfile_#{Process.pid} for file uploads

        mycsv = CSV.parse(File.read(myfile), :headers => :first_row)
        mycsv.each do |data|
          myrowhash = data.to_hash
          myrowhash.delete(nil)
          eval(m).create(myrowhash)
        end
        
        puts "--  = " + i.to_s + " records"
      else
        puts "-- Did not find file " + tempfile.to_s
      end #file exist
    end

#First user is the placeholder for unassigned representatives
#  The login is not intended for use, so here its set to creator/admin without admin privilages
User.create!(name: "TBD",
                 email: "foobar@gmail.com",
                 password: "2014notforlogingin",
                 password_confirmation: "2014notforlogingin",
                 phone: "7186785933",
                 phonetype: "boost",
                 schedule: true,
                 admin: false)
User.create!(name: "Ted",
                 email: "teddottavio@yahoo.com",
                 password: "foobar",
                 password_confirmation: "foobar",
                 phone: "7186785933",
                 phonetype: "boost",
                 schedule: true,
                 admin: true)
User.create!(name: "SA Staff",
                 email: "infrared@soundassociates.com",
                 password: "distribution",
                 password_confirmation: "distribution",
                 phone: "7186785933",
                 phonetype: "boost",
                 schedule: false,
                 admin: true)
User.create!(name: "Joe The Test Account",
                 email: "joe@gmail.com",
                 password: "foobar",
                 password_confirmation: "foobar",
                 phone: "7186785933",
                 phonetype: "boost",
                 schedule: true,
                 admin: false)
User.create!(name: "Anne Tramon",
                 email: "annetramon@prodigy.net",
                 password: "distribution",
                 password_confirmation: "distribution",
                 phone: "9147602063",
                 phonetype: "at&t",
                 schedule: false,
                 admin: true)
User.create!(name: "Carl Anthony Tramon",
                 email: "carlanthonytramon7@prodigy.net",
                 password: "foobar",
                 password_confirmation: "foobar",
                 phone: "7737936585",
                 phonetype: "at&t",
                 schedule: false,
                 admin: true)
User.create!(name: "Wambui",
                 email: "wambui@wambui.com",
                 password: "wambui",
                 password_confirmation: "wambui",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Adam Shonkwiler",
                 email: "adamshonkwiler@gmail.com",
                 password: "adamshonkwiler",
                 password_confirmation: "adamshonkwiler",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Anna Lively",
                 email: "anna@annalively.com",
                 password: "annalively",
                 password_confirmation: "annalively",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Anthony Raus",
                 email: "anthonyraus@gmail.com",
                 password: "anthonyraus",
                 password_confirmation: "anthonyraus",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Anya Aliferis",
                 email: "anya.aliferis@gmail.com",
                 password: "anya.aliferis",
                 password_confirmation: "anya.aliferis",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Ashley Griffin",
                 email: "faeriebleue@aol.com",
                 password: "faeriebleue",
                 password_confirmation: "faeriebleue",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Beth Anne Sacks",
                 email: "bethannesacks@gmail.com",
                 password: "bethannesacks",
                 password_confirmation: "bethannesacks",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Beth Naji",
                 email: "bnajishow@aol.com",
                 password: "bnajishow",
                 password_confirmation: "bnajishow",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Bobby Matteau",
                 email: "bobby.matteau@gmail.com",
                 password: "bobby.matteau",
                 password_confirmation: "bobby.matteau",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "C K Browne",
                 email: "ckendallbrowne@gmail.com",
                 password: "ckendallbrowne",
                 password_confirmation: "ckendallbrowne",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Camron Gran",
                 email: "camrongran@hotmail.com",
                 password: "camrongran",
                 password_confirmation: "camrongran",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Carla Cherry",
                 email: "carlaremy@gmail.com",
                 password: "carlaremy",
                 password_confirmation: "carlaremy",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Cathleen Wright",
                 email: "cathleen@cathleenwright.com",
                 password: "cathleen",
                 password_confirmation: "cathleen",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Cindy",
                 email: "cinshee@aol.com",
                 password: "cinshee",
                 password_confirmation: "cinshee",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Cynthia Ladopoulos",
                 email: "nycindytours@gmail.com",
                 password: "nycindytours",
                 password_confirmation: "nycindytours",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "D. Levy",
                 email: "levdm5@gmail.com",
                 password: "levdm5",
                 password_confirmation: "levdm5",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Dakota DeFelice",
                 email: "dakotadefelice@gmail.com",
                 password: "dakotadefelice",
                 password_confirmation: "dakotadefelice",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Dani Marcus",
                 email: "danimarcus2002@yahoo.com",
                 password: "danimarcus2002",
                 password_confirmation: "danimarcus2002",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "David Kellner",
                 email: "david_kellner7@hotmail.com",
                 password: "david_kellner7",
                 password_confirmation: "david_kellner7",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Denise Bourcier",
                 email: "dabourcier@gmail.com",
                 password: "dabourcier",
                 password_confirmation: "dabourcier",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Devin Vogel",
                 email: "devin.i.vogel@gmail.com",
                 password: "devin.i.vogel",
                 password_confirmation: "devin.i.vogel",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Edward Batchelor",
                 email: "ebatchelor72@gmail.com",
                 password: "ebatchelor72",
                 password_confirmation: "ebatchelor72",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Eileen F. Dougherty",
                 email: "efdoughert@aol.com",
                 password: "efdoughert",
                 password_confirmation: "efdoughert",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Emily Adamo",
                 email: "emilyeadamo@gmail.com",
                 password: "emilyeadamo",
                 password_confirmation: "emilyeadamo",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Emily Rhein",
                 email: "emily.rhein@gmail.com",
                 password: "emily.rhein",
                 password_confirmation: "emily.rhein",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Erika Jenko",
                 email: "onceuponareality@gmail.com",
                 password: "onceuponareality",
                 password_confirmation: "onceuponareality",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Gigi Soriano",
                 email: "gigisoriano811@gmail.com",
                 password: "gigisoriano811",
                 password_confirmation: "gigisoriano811",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Gregory Bertolini",
                 email: "gregbertolini@yahoo.com",
                 password: "gregbertolini",
                 password_confirmation: "gregbertolini",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Jacqueline Keeley",
                 email: "jackiekeeley@gmail.com",
                 password: "jackiekeeley",
                 password_confirmation: "jackiekeeley",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Jane Moore",
                 email: "jmoore1@gm.slc.edu",
                 password: "jmoore1",
                 password_confirmation: "jmoore1",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Jane Van gelder",
                 email: "janevangelder@yahoo.com",
                 password: "janevangelder",
                 password_confirmation: "janevangelder",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Jelissa Mercado",
                 email: "jelissam21@gmail.com",
                 password: "jelissam21",
                 password_confirmation: "jelissam21",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Jennifer Cooper",
                 email: "jenlizcooper@gmail.com",
                 password: "jenlizcooper",
                 password_confirmation: "jenlizcooper",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Jennifer Menter",
                 email: "jennifer.menter@gmail.com",
                 password: "jennifer.menter",
                 password_confirmation: "jennifer.menter",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Julien Braun",
                 email: "julienbraun@icloud.com",
                 password: "julienbraun",
                 password_confirmation: "julienbraun",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Kelsey Matta",
                 email: "kelseymatta@gmail.com",
                 password: "kelseymatta",
                 password_confirmation: "kelseymatta",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Kingsley Leggs",
                 email: "kingsleyleggs@gmail.com",
                 password: "kingsleyleggs",
                 password_confirmation: "kingsleyleggs",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Kristy Lee",
                 email: "kristylee118@aol.com",
                 password: "kristylee118",
                 password_confirmation: "kristylee118",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Krystal Sobaskie",
                 email: "krystal.sobaskie@gmail.com",
                 password: "krystal.sobaskie",
                 password_confirmation: "krystal.sobaskie",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Kurt Perry",
                 email: "kurt.perry41@gmail.com",
                 password: "kurt.perry41",
                 password_confirmation: "kurt.perry41",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Larissa Laurel",
                 email: "larissalaurel@gmail.com",
                 password: "larissalaurel",
                 password_confirmation: "larissalaurel",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Lotte de Roy",
                 email: "lottederoy@hotmail.com",
                 password: "lottederoy",
                 password_confirmation: "lottederoy",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Melvin Abston",
                 email: "melvin.abston@gmail.com",
                 password: "melvin.abston",
                 password_confirmation: "melvin.abston",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Nancy Swiezy",
                 email: "nancyswiezyevents@gmail.com",
                 password: "nancyswiezyevents",
                 password_confirmation: "nancyswiezyevents",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Nikki Stephenson",
                 email: "nikkistephenson12@gmail.com",
                 password: "nikkistephenson12",
                 password_confirmation: "nikkistephenson12",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Patricia Einstein",
                 email: "yespatriciaeinstein@yahoo.com",
                 password: "yespatriciaeinstein",
                 password_confirmation: "yespatriciaeinstein",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Paul Bolter",
                 email: "pbolter1@gmail.com",
                 password: "pbolter1",
                 password_confirmation: "pbolter1",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Peter G",
                 email: "pgulczewski@gmail.com",
                 password: "pgulczewski",
                 password_confirmation: "pgulczewski",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Rachel Leighson",
                 email: "rsmithweinstein@gmail.com",
                 password: "rsmithweinstein",
                 password_confirmation: "rsmithweinstein",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Rita Rehn",
                 email: "ritarehn@aol.com",
                 password: "ritarehn",
                 password_confirmation: "ritarehn",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Robert Matteau",
                 email: "bobby.matteau@icloud.com",
                 password: "bobby.matteau",
                 password_confirmation: "bobby.matteau",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Saundra Addison",
                 email: "saundra_addison@yahoo.com",
                 password: "saundra_addison",
                 password_confirmation: "saundra_addison",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Standley McCray",
                 email: "standley.mccray@gmail.com",
                 password: "standley.mccray",
                 password_confirmation: "standley.mccray",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Star Soriano",
                 email: "starsoriano@gmail.com",
                 password: "starsoriano",
                 password_confirmation: "starsoriano",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Stephanie Serfecz",
                 email: "stephanieserfecz@gmail.com",
                 password: "stephanieserfecz",
                 password_confirmation: "stephanieserfecz",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Triston John",
                 email: "trisjohn@gmail.com",
                 password: "trisjohn",
                 password_confirmation: "trisjohn",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Vanessa Dawson",
                 email: "vanessagdawson@gmail.com",
                 password: "vanessagdawson",
                 password_confirmation: "vanessagdawson",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)
User.create!(name: "Hy Chait",
                 email: "hychait@nomail.com",
                 password: "hychait",
                 password_confirmation: "hychait",
                 phone: "",
                 phonetype: "",
                 schedule: true,
                 admin: false)

#use FactoryGirl to make a few more users
#(0..20).each do |u|
  #fakename = Faker::Name.name
  #fakeemail = fakename + u + "@gmail.com"
#  User.create!(name: Faker::Name.name,
#                 email: Faker::Internet.email,
#                 password: "foobar",
#                 password_confirmation: "foobar",
#                 phone: Faker::PhoneNumber.phone_number,
#                 phonetype: "",
#                 schedule: true,
#                 admin: false)
#end
#JUST IN CASE
# Factory girl might mess up heroku deployment:
#  http://stackoverflow.com/questions/12423273/factorygirl-screws-up-rake-dbmigrate-process



#Language
#0 Mix Board
#1 iCaption
#2 Description
#3 Chinese
#4 French
#5 German
#6 Japanese
#7 Portugese
#8 Spanish
#9 Turkish
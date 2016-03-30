# Rake db:addscans

namespace :db do
  desc "Add scanned logs to db"
  task :addscans => :environment do
    require 'fileutils'

    puts "Cleaning out the db"
    ActiveRecord::Base.transaction do
      Scan.destroy_all
    end

    puts "Adding Files"

    yearlist = Dir.glob("app/assets/images/2*")
    yearlist.each do |y|
      puts "adding year" + y.split("/").last
      idlist = Dir.glob( y.to_s + "/*")
      idlist.each do |i|
        scanlist = Dir.glob( i.to_s + "/*.jpg")
        scanlist.each do |scan|
          filename = scan.split("/").last
          mondayarray = filename.split("-")
          id = filename.split("-").first
          if filename.split("-").last.split(".").first == "1" then
            ss = true
          else
            ss = false
          end
          monday = DateTime.new(mondayarray[1].to_i, mondayarray[2].to_i, mondayarray[3].to_i)

          ActiveRecord::Base.transaction do
            obj = Scan.new(performance_id: id, monday: monday, specialservices: ss)
            obj.save
          end

       end
     end
   end

  puts "all jpg files scanned added. This reset Scan.id's and relies on the Scans.rb controller to record files..."
  end #task
end
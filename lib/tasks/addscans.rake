# Rake db:addscans

namespace :db do
  desc "Add scanned logs to db"
  task :addscans => :environment do
    require 'fileutils'

    puts "Cleaning out the Scans db table"
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

task :runme => :environment do
  #kwik fix thingy...  puts Distributed.onday(weekstart-730).inspect
  weekstart = DateTime.now.utc.beginning_of_day - 691
    loop do
      break if weekstart.wday == 1
      weekstart = weekstart - 1.day
    end
    
  puts weekstart
  obj = Distributed.datespan(weekstart, weekstart+6)
  count = 0
  
  obj.each do
    puts Performance.find(obj[count].performance_id).name
    puts obj[count].curtain.strftime('%A - %b %d')
    Distributed.find(obj[count].id).destroy
    count += 1
    puts "----"
  end
  
end

end
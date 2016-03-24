# Rake db:migrate_20160324

namespace :db do
  desc "Sets booleans for Infrared Product and scanned sheets"
  #http://www.stackoverflow.com/questions/876396/do-rails-rake-tasks-provide-access-to-activerecord-models

  task :migrate_20160324 => :environment do
    puts "Setting all isinfrared booleans to false"
    Distributed.update_all(isinfrared: false)
    puts "selecting all distributeds by product id"
    #NOT using the .infrared scope because that needs to be depreciated after this migration
    obj = Distributed.where(product_id: [1,3,6,7])
    obj.update_all(isinfrared: true)
    puts obj.count
    puts "Completed"

    puts"Review each performance, one week at a time, and set scans boolean to each shift record of Distributeds"
    #Select a each week of one performance - check for scan - set sacns boolean

=begin
    performanceidlist = Distributed.allperformances(params[:xportweekstart].to_date, params[:xportweekstart].to_date + 7)

    performanceidlist.each do |p|
        logimage = findlog(params[:xportweekstart].to_date, p, 1)
        sslogimage = findlog(params[:xportweekstart].to_date, p, 2)
        if !logimage.nil? then @viewlist.push(logimage) end
        if !sslogimage.nil? then @viewlist.push(sslogimage) end
    end
=end

  end #task
end
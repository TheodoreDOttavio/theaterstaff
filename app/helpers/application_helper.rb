module ApplicationHelper
  def full_title(page_title)
    base_title = "Theater Staff Schedule"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end


  def findlog(astart, performanceid, format)
    loop do
      break if astart.wday == 1
      astart = astart - 1.day
    end
    logfile = astart.strftime('%Y') + "/" +
          performanceid.to_s + "/" +
          performanceid.to_s + "-" +
          astart.strftime('%Y-%m-%d') + "-" + format.to_s + ".jpg"
    if File.exist?("app/assets/images/" + logfile) then
      return logfile
    end
  end

# Functions for text messaging Representatives
  def config_yaml
     @config_yaml ||= YAML::load(File.open("#{Rails.root}/db/sms_carriers.yml"))
  end

  def carriers
    config_yaml['carriers']
  end

  # Returns a collection of carriers for form_to select tags
  #  <%= f.select :phonetype, carrier_collection %>
  def carrier_collection
    carriers.sort.collect{ |carrier| [carrier[1]["name"], carrier[0]] }
  end
end

def archivedate(databasedate)
  mydatearray = databasedate.to_s[0..9].split("-").map { |s| s.to_i }

  if mydatearray.length == 3 then
    mydate = DateTime.new(mydatearray[0], mydatearray[1], mydatearray[2])
  else
    mydate = DateTime.strptime("2014-10-04 20:00:00 UTC"[0..9], '%Y-%m-%d')
  end

  showdate = mydate.strftime('%b %d, \'%y')
  return showdate
end
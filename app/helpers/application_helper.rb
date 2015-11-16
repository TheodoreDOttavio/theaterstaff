module ApplicationHelper
  # Returns the full title on a per-page basis.
  def full_title(page_title)
    base_title = "Theater Staff Schedule"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end


  def showdate(databasedate)
    #ok... seriously can't get this in the view or here in the controller
    # the if-then saved the day but the bogus date never shows!!!

    #no with flavors of strptime
    #mydate = DateTime.strptime("2014-11-04 20:00:00 UTC"[0..9], '%Y-%m-%d')
    #mydate = DateTime.strptime(databasedate.to_s[0..9], '%Y-%m-%d' )

    #and no to .parse
    #mydate = DateTime.parse(databasedate.to_s)
    #mydate = DateTime.httpdate(databasedate.to_s)
    #mydate = DateTime.iso8601(databasedate.to_s)

    # tried dateTime.new(2014,11,4) it works.
    mydatearray = databasedate.to_s[0..9].split("-").map { |s| s.to_i }

    if mydatearray.length == 3 then
      mydate = DateTime.new(mydatearray[0], mydatearray[1], mydatearray[2])
      #mydate = DateTime.new(mydatearray.at(0), mydatearray.at(1), mydatearray.at(2))
    else
      mydate = DateTime.strptime("2014-10-04 20:00:00 UTC"[0..9], '%Y-%m-%d')
    end

    if mydate.strftime('%I').to_f > 4 then
      showdate = mydate.strftime('%a') + " E " + mydate.strftime('%m / %d')
    else
      showdate= mydate.strftime('%a') + " M " + mydate.strftime('%m / %d')
    end

    return showdate
  end

  def curtaintotheaterdate(curtaindate)
    mydate = DateTime.now
    mydatearray = curtaindate.to_s[0..9].split("-").map {|s| s.to_i }

    if mydatearray.length == 3 then
      mydate = DateTime.new(mydatearray[0],mydatearray[1],mydatearray[2])
    end

    if mydate.strftime('%I').to_f > 4 then
      theaterdate = mydate.strftime('%a') + " E  " + mydate.strftime('%m / %d')
    else
      theaterdate = mydate.strftime('%a') + " M  " + mydate.strftime('%m / %d')
    end

    return theaterdate
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


  def config_yaml
     @config_yaml ||= YAML::load(File.open("#{Rails.root}/config/sms_carriers.yml"))
  end

  def carriers
    config_yaml['carriers']
  end

  # Returns a collection of carriers for form_to select tags
  #  <%= f.select :phonetype, carrier_collection %>
  def carrier_collection
    carriers.sort.collect{ |carrier| [carrier[1]["name"], carrier[0]] }
  end

  # Returns a formatted select box filled with carriers
  #   <%= carrier_select %>
  # - name => name of the method in which you want to store the carrier name
  # - phrase => default selected blank option in select box
  # - selected => carrier to pre-select
  def carrier_select(name = :mobile_carrier,
      phrase = "Select a Carrier",
      selected = nil,
      include_blank = true)
    options = phrase.nil? ? carrier_collection : include_blank ? [phrase,nil] + carrier_collection : [phrase] + carrier_collection
    select_tag name, options_for_select(options, selected || phrase)
  end
  
  
    def shortname(myname)
    mynamearray = myname.split(" ")
    mynewname = mynamearray[0]
    if mynamearray.count > 1 then
      mynewname += " " + mynamearray[1][0..0]
    end
    return mynewname
  end


  def posttext (post)
    if post == 1 then
      return "main console"
    else
      return "alternative console"
    end
  end

  def shortdate (mydate) #this function has been depreciated
    #.strftime('%a: %b %d at %I:%M %p')
    if mydate.strftime('%I').to_f > 4 then
      mytimeslot = "Eve" #evening
    else
      mytimeslot = "Mat" #matine
    end

    #mydate.strftime('%a ') + mytimeslot + mydate.strftime(' %I:%M')
    mydate.strftime('%A ') + mytimeslot + mydate.strftime(' %m/%d')
  end

  def workshift(mycurtain, myduration)
    #Start one hour before curtain time, and stay 1/2 hour after
    if myduration < 1 then
      myduration = 180
    end
    myduration = myduration + 30

    thisshift = (mycurtain - 1.hour).strftime(' %I:%M%P') +
      " - " + (mycurtain + myduration.minutes).strftime(' %I:%M%P')

    return thisshift
  end

  def dateselector (hrmin)
    #hrmin as string "07:30"
    #2014-06-03T02:00:00-04:00
    #mytimestring = (DateTime.now.wday + (d-7)).day.ago

    #DateTime.now.strftime("%Y-%m-%dT%H:%M:%S-04:00")
    mytimestring = DateTime.now.strftime("%Y-%m-%d") + "T" + hrmin + ":00-04:00"
  end

  def weekstart
    astart = DateTime.now.utc.beginning_of_day
    loop do
      break if astart.wday == 1
      astart = astart - 1.day
    end
    weekstart = astart
    return weekstart
  end


  def dayindex
    #for use with .each_index so shift monday to 0 and set Sunday
    todayis = DateTime.now.beginning_of_day

    if todayis.wday == 0 then
      dayindex = 6
    else
      dayindex = (todayis.wday.to_i) - 1
    end
  end

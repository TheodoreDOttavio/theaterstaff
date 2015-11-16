class AvailablesController < ApplicationController
  def index
  end

  def show
    #Use the show controller to capture User ID

    #default to this week for data entry
    mystart = weekstart
    @mystart = mystart + 7
    @weekofavailable = []
    @thisweekofavailable = []

    checkadmin = User.find(params[:id])
    if checkadmin.admin? then
      #Show all users, AND two weeks
      User.where("schedule = 't'").order(:name).each do |u|
        @weekofavailable.push(Availabledataentrybyuser(mystart, u.id))
        @thisweekofavailable.push(Availabledataentrybyuser(mystart-7, u.id))
      end
    else
      @weekofavailable.push(Availabledataentrybyuser(mystart, params[:id]))
    end
  end


  def new
  end


  def create
    #The receives several Availables ID's so it will create and delete
    #  No updateing because we're dealing with boolean. It's in the data or it's not.
    params.permit!
    myflashtext = ""
    i=0

    while params[('available'+i.to_s).to_sym] != nil do
    myparams = params[('available'+i.to_s).to_sym]

    if myparams[:quickfill_none] == "1" then
      for x in 0..13 do
        myparams = params[('available' + (i-x).to_s).to_sym]
        myparams[:free] = "0"
        createpartial(myparams)
      end
      thisuser = User.find(myparams[:user_id])
      myflashtext += "<br />All availability removed for " + thisuser.name
      #i += 1
      #myparams = params[('available'+i.to_s).to_sym]
    end

    if myparams[:quickfill_all] == "1" then
      for x in 0..13 do
        myparams = params[('available' + (i-x).to_s).to_sym]
        myparams[:free] = "1"
        createpartial(myparams)
      end
      thisuser = User.find(myparams[:user_id])
      myflashtext += "<br />All shifts added for " + thisuser.name
      #i += 1
      #myparams = params[('available'+i.to_s).to_sym]
    end

    if myparams[:quickfill_eve] == "1" then
      for x in 4..13 do
        myparams = params[('available' + (i-x).to_s).to_sym]
        if myparams[:eve] == "true" then
          myparams[:free] = "1"
          createpartial(myparams)
        end
      end
      thisuser = User.find(myparams[:user_id])
      myflashtext += "<br />Evenings added for " + thisuser.name
      #myparams = params[('available'+i.to_s).to_sym]
    end

    if myparams[:quickfill_satsun] == "1" then
      for x in 0..3 do
        myparams = params[('available' + (i-x).to_s).to_sym]
        myparams[:free] = "1"
        createpartial(myparams)
      end
      thisuser = User.find(myparams[:user_id])
      myflashtext += "<br />Weekends added for " + thisuser.name
      #i += 1
      #myparams = params[('available'+i.to_s).to_sym]
    end

    myflashtext += createpartial(myparams)[1]

    i += 1
    end

    if myflashtext != "" then
      flash[:update] = "Availability has been updated<br /> " + myflashtext
    end
    redirect_to available_path(current_user)
  end

  def edit
  end

  def update
  end

  def destroy
  end

 private
    def availables_params
      params.require(:available).permit(:id,
        :day,
        :eve)
    end


    def Availabledataentrybyuser(mydate, myuserid)
     #set up seven days, Matine and evening (14 entries)
     weekofavailable = Array.new(14)

     thisdate = mydate.to_date - 1.day
     thiseve = true #matine
     userid = myuserid.to_i

     weekofavailable.each_with_index do |d, i|

     if thiseve == true then
        thisdate = thisdate + 1
        thiseve = false
     else
        thiseve = true
     end

     #find existing records
     availablesearch = Available.onday(thisdate).where(eve: thiseve,
         user_id: userid)

     if availablesearch.count == 0 then
       weekofavailable[i] = Available.new(user_id: userid,
            day: thisdate,
            eve: thiseve,
            free: 0)
     else
       weekofavailable[i] = Available.new(user_id: userid,
            day: thisdate,
            eve: thiseve,
            id: availablesearch.first.id,
            free: 1)
       end
     end

     return weekofavailable
    end


    def createpartial(myparams)
      partialflashtext = ""
      returnflashtext = ""

      if myparams[:free] != "0" then
        #checked. if there's an ID, move on..
        if Available.where(id: myparams[:id]).exists? == false then
          myparams = myparams.except(:quickfill_none)
          myparams = myparams.except(:quickfill_all)
          myparams = myparams.except(:quickfill_eve)
          myparams = myparams.except(:quickfill_satsun)

          @available = Available.new(myparams)
          @available.save
          partialflashtext += myparams[:day].to_date.strftime('+ %a ')
          if myparams[:eve] == "true" then
            partialflashtext += "Eve "
          else
            partialflashtext += "Mat "
          end
        end
      else
        #nothing checked... Destroy if this has an ID
        if Available.where(id: myparams[:id]).exists? then
          Available.find(myparams[:id]).destroy
          partialflashtext += myparams[:day].to_date.strftime('- %a ')
          if myparams[:eve] == "true" then
            partialflashtext += "Eve "
          else
            partialflashtext += "Mat "
          end
        end
      end

      if partialflashtext != "" then
        thisuser = User.find(myparams[:user_id])
        returnflashtext = "<br />Shifts for " + thisuser.name
        returnflashtext += " " + partialflashtext
      end

      return myparams, returnflashtext
    end

end
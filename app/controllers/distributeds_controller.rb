class DistributedsController < ApplicationController
  def show
  end


  def index
  if current_user.admin?
    if params[:mystart] then
      @mystart = params[:mystart].to_date
    else
      @mystart = weekstart
    end

    @weekof = @mystart.strftime('%b %d')+" to "+ (@mystart+7).strftime('%b %d, %Y')

    performances = Performance.showinglist(@mystart)
    @showstoedit = []
    performances.each do |p|
      mycount = Distributed.datespan(@mystart, (@mystart+7)).where('performance_id = ?', p.id).count
      if mycount != 0 then
        @showstoedit.push([p.name[0..16],p.id,"btn btn-sm btn-primary"])
      else
        @showstoedit.push([p.name[0..16],p.id,"btn btn-sm btn-danger"])
      end
    end


    #Display where the data is at - overview of what has been entered
    @weektoedit = Array.new
    @weekstartstoedit = []
    for i in 1..104 do
      mystart = weekstart - (i * 7)

      #add in some info about what has been entered
      myshowcount = Performance.showingcount(mystart, (mystart+7))
      myinfraredcount = Distributed.infraredwkcount(mystart)
      myscanscount = Scan.scanscount(mystart)
      myssscanscount = Scan.ssscanscount(mystart)
      myshiftcount = Distributed.shiftwkcount(mystart)
      myrepcount = Distributed.representativewkcount(mystart)
      mytbdrepcount = Distributed.representativetbdwkcount(mystart)

      if myinfraredcount == 0 then #&& myspecialservicescount == 0 then
        mybuttonclass = "btn btn-sm btn-danger"
      else
        if myinfraredcount < myshowcount then
          mybuttonclass = "btn btn-sm btn-warning"
        else
          mybuttonclass = "btn btn-sm btn-primary"
        end
      end

      @weektoedit.push({"showweekof" => mystart.strftime('%b %d')+" to "+ (mystart+7).strftime('%b %d, %Y'),
        "startdate" => mystart,
        "showcount" => myshowcount,
        "infraredcount" => myinfraredcount,
        "scanscount" => myscanscount.to_s + " - " + myssscanscount.to_s,
        "shiftcount" => myshiftcount,
        "repcount" => myrepcount,
        "tbdcount" => mytbdrepcount,
        "buttonclass" => mybuttonclass})
    end
  else
    redirect_to root_url
  end
  end


  def new
  if current_user.admin?
    #default to this week for data entry
    mystart = params[:mystart].to_date
    @mystart = mystart
    @weekof = @mystart.strftime('%b %d')+" to "+ (@mystart+7).strftime('%b %d, %Y')

    #Get the Show
    @performance = Performance.find(params[:performance_id])

    #Provide names for the Language integer
    @language = Shortlists.new.languages

    #show/assign a rep to each shift for events
    users = User.select(:name, :id).order(:name)
    @representatives = []
    @representatives.push(['unknown',1])
    users.each do |u|
      @representatives.push([u.name,u.id])
    end

    #@weekbyshow = Hash.new
    @weekofdistributed = [] #-depreciate this line
    @performance.cabinets.each do |c|
      if c.product.options > 0 then
        #@weekbyshow['productname'] = c.product.name
        #@weekbyshow['partialtype'] = c.product.options #1 for infrared, 2 for language special services
        #@weekbyshow['dataentry'] = Distributeddataentrybyproduct(mystart, params[:performance_id], c.product.id)
        #-depreciate next line
        @weekofdistributed = @weekofdistributed + Distributeddataentrybyproduct(mystart, params[:performance_id], c.product.id)
      end
    end

    @distributed = Distributed.new
  else
    redirect_to root_url
  end
  end


  def create
  if current_user.admin?
    #The receives several Distributed ID's so it will update as well
    params.permit!

    @language = Shortlists.new.languages
    myflashtext = ""
    i=0

    #find the id the selected 'weekofrepresentative'
    myparams = params['distributed0'.to_sym]
    weekofrepresentative = myparams[:weekofrepresentative]

    while params[('distributed'+i.to_s).to_sym] != nil do
    myparams = params[('distributed'+i.to_s).to_sym]

    if myparams[:quantity] != "" # Do NOT add quantities left blank (nil)
      #add id the selected 'weekofrepresentative'
      myparams[:representative] = weekofrepresentative if myparams[:representative].to_i <= 1 or nil

      if myparams[:id] != ""
        #update one
        obj = Distributed.find(myparams[:id])
        obj.update_attributes(myparams)
        myflashtext += " updated - " + myparams[:quantity] + " on "
        myflashtext += myparams[:curtain].to_date.strftime('%a E (%m / %d)')
        #myflashtext = myflashtext + myparams[:language].key(distributed.language.to_i)
      else
        #create one
        if myparams[:product_id].to_i == 1 or myparams[:product_id].to_i == 6 #Zero quantites are ONLY for headsets (product_id=1)
          obj = Distributed.new(myparams)
          obj.save
        else
          if myparams[:quantity].to_i > 0
            obj = Distributed.new(myparams)
            obj.save
          end
       end
       myflashtext += " added - " + myparams[:quantity] + " on "
       myflashtext += myparams[:curtain].to_date.strftime('%a E (%m / %d)')
     end
    else
      #null qty, so do we delete.
      if myparams[:id] != ""
        Distributed.find(myparams[:id]).destroy

        myflashtext += " deleted - "
        myflashtext += myparams[:curtain].to_date.strftime('%a E (%m / %d)')
        #myflashtext += myparams[:language].key(distributed.language.to_i)
      end
    end

    i = i+1
    end

    show_name = Performance.find(myparams[:performance_id])
    flash[:success] = "Distribution:" + myflashtext + " for " + show_name.name
    mystart = params[:distributed0][:curtain].to_date
    redirect_to distributeds_path(:mystart => mystart)
  else
    redirect_to root_url
  end
  end


  def edit
  end


  def update
  end


  def destroy
  end



  private

    def Distributeddataentrybyproduct(mydate, myperformanceid, myproductid)

     #set up seven days, Matine and evening (14 entries) search for existing dist

     productsearch = Product.find(myproductid)
     if productsearch.options > 1 then
       my_language = 9 #so it loops back to 1...
       weekofdistributed = Array.new(140)
     else
       my_language = 0
       weekofdistributed = Array.new(14)
     end

     thisdate = mydate.to_date
     thiseve = false #matine
     performanceid = myperformanceid.to_i
     productid = myproductid.to_i
     thislang = -1


     weekofdistributed.each_with_index do |d, i|

       #count through languages
       thislang = thislang + 1
       if thislang > my_language then
         #reset thislang and toggle evenings and matine's
         thislang = 0
         if thiseve == true then
           thisdate = thisdate + 1
           thiseve = false
         else
           thiseve = true
         end
       end

       #find existing records
       distributedsearch = Distributed.onday(thisdate).where(eve: thiseve,
         product_id: productid,
         performance_id: performanceid,
         language: thislang)

       if distributedsearch.count == 0 then
         weekofdistributed[i] = Distributed.new(performance_id: performanceid,
            curtain: thisdate,
            eve: thiseve,
            product_id: productid,
            language: thislang,
            representative: 0)
       else
         #A data cleaner
         #  for legacy data
         distributedsearch.each do |doppleganger|
           if distributedsearch.count !=1 then
             Distributed.find(distributedsearch.last.id).destroy
             flash[:error] = "Duplicate entry was removed"
           end
         end
         #End data cleaner

         weekofdistributed[i] = Distributed.new(performance_id: performanceid,
            curtain: thisdate,
            eve: thiseve,
            product_id: productid,
            language: thislang,
            representative: distributedsearch.first.representative,
            id: distributedsearch.first.id,
            quantity: distributedsearch.first.quantity)
       end
     end


     return weekofdistributed
    end

end

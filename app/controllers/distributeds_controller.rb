class DistributedsController < ApplicationController
  def show
  end


  def index
  if current_user.admin?
    mystart = weekstart
    myend = mystart + 7
    @mystart = mystart-7
    @weekof = mystart.strftime('%b %d')+" to "+ myend.strftime('%b %d, %Y')

    #to edit, we want to go by the week,
    #  so pass dates in the params for preedit -- new/create/update
    #  and jump to predit
    @weekstartstoedit = []
    for i in 1..104 do
      mystart = weekstart - (i * 7)
      myend = mystart + 6
      #add in some info about what has been enetered
      myshowcount = Performance.showingcount(mystart, (mystart+7))

      myinfraredcount = Distributed.infraredwkcount(mystart)
      myspecialservicescount = Distributed.specialservicecount(mystart, (mystart+7))
      myrepcount = Distributed.representativecount(mystart, (mystart+7))

      if myinfraredcount == 0 && myspecialservicescount == 0 then
        mybuttonclass = "btn btn-sm btn-danger"
      else
        if myinfraredcount < myshowcount then
          mybuttonclass = "btn btn-sm btn-warning"
        else
          mybuttonclass = "btn btn-sm btn-primary"
        end
      end

      @weekstartstoedit.push([mystart.strftime('%b %d')+" to "+ myend.strftime('%b %d, %Y'),
        mystart,
        myshowcount,
        myinfraredcount,
        myspecialservicescount,
        myrepcount,
        mybuttonclass])
    end
  else
    redirect_to root_url
  end
  end

  def preedit
  if current_user.admin?
    #come into this with a mystart and here we select the theater
    #  and then this goes to Create for create/udate/delete
    mystart = params[:mystart].to_date
    @mystart = mystart

    #List open shows for the new... and ultimatly create/update controller
    performances = Performance.where("closeing >= ? and opening <= ?", mystart, mystart).select(:id, :name).order(:name)
    #here...list buttons and color based on data entered
    @showstoedit = []

    performances.each do |p|
      mycount = Distributed.datespan(mystart, (mystart+7)).where('performance_id = ?', p.id).count
      if mycount != 0 then
        @showstoedit.push([p.name[0..16],p.id,"btn btn-small btn-primary"])
      else
        @showstoedit.push([p.name[0..16],p.id,"btn btn-small btn-danger"])
      end
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

    #Get the Show Name
    @performance = Performance.find(params[:performance_id])

    #Provide names for the Language integer
    @language = languagelist

    #show/assign a rep to each shift for events
    users = User.select(:name, :id)
    @representatives = []
    users.each do |u|
      @representatives.push([u.name,u.id])
    end

     @weekofdistributed = []
     @performance.cabinets.each do |c|
       if c.product.options > 0 then
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
    #The receives several Distributed ID's so it will update as well!
    params.permit!

    @language = languagelist
    myflashtext = ""
    i=0

    while params[('distributed'+i.to_s).to_sym] != nil do
    myparams = params[('distributed'+i.to_s).to_sym]

    if myparams[:quantity] != "" # Do NOT add quantities left blank (nil)
     if myparams[:id] != ""
       #update one
         @distributed = Distributed.find(myparams[:id])
         @distributed.update_attributes(myparams)
         myflashtext = myflashtext + " updated - "
         myflashtext = myflashtext + myparams[:curtain].to_date.strftime('%a E (%m / %d)')
         #myflashtext = myflashtext + myparams[:language].key(distributed.language.to_i)
     else
       #create one
       if myparams[:product_id].to_i == 1  #Zero quantites are ONLY for headsets (product_id=1)
         @distributed = Distributed.new(myparams)
         @distributed.save
       else
         if myparams[:quantity].to_i > 0
           @distributed = Distributed.new(myparams)
           @distributed.save
         end
       end
       myflashtext = myflashtext + " added - "
       myflashtext = myflashtext + myparams[:curtain].to_date.strftime('%a E (%m / %d)')
       #myflashtext = myflashtext + myparams[:language].key(distributed.language.to_i)
     end
    else
      #null qty, so do we delete.
      if myparams[:id] != ""
        Distributed.find(myparams[:id]).destroy

        myflashtext = myflashtext + " deleted - "
        myflashtext = myflashtext + myparams[:curtain].to_date.strftime('%a E (%m / %d)')
        #myflashtext = myflashtext + myparams[:language].key(distributed.language.to_i)
      end
    end

    i = i+1
    end

    show_name = Performance.find(myparams[:performance_id])
    flash[:success] = "Distribution:" + myflashtext + " for " + show_name.name
    mystart = params[:distributed0][:curtain].to_date
    redirect_to preedit_path(:mystart => mystart)
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
    def distributed_params
      params.require(:distributed).permit(:curtain,
        :quantity,
        :eve,
        :language,
        :product_id,
        :performance_id,
        :representative )
    end


    def Distributeddataentrybyproduct(mydate, myperformanceid, myproductid)

     #set up seven days, Matine and evening (14 entries) search for existing dist

     productsearch = Product.find(myproductid)
     if productsearch.options > 1 then
       #{:Infrared=>0, :iCaption=>1, :dScript=>2, :Chinese=>3, :French=>4, :German=>5, :Japanese=>6, :Portugese=>7, :Spanish=>8, :Turkish=>9}
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
     #representative_id = 1


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
         eventsearch = Event.onday(thisdate).where(eve: thiseve,
           performance_id: performanceid)

         if eventsearch.empty? then
           representative_id = 1
         else
           representative_id = eventsearch.user_id
         end

         weekofdistributed[i] = Distributed.new(performance_id: performanceid,
            curtain: thisdate,
            eve: thiseve,
            product_id: productid,
            language: thislang,
            representative: representative_id)
       else
         #ok, ... its a shitty place to do this, but here's a data cleaner
         #  for legacy crap data
         distributedsearch.each do |doppleganger|
           if distributedsearch.count !=1 then
             Distributed.find(distributedsearch.last.id).destroy
             flash[:error] = "Duplicate entry was removed"
           end
         end
         # and thats the spitshine polish... one data entry at a time

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

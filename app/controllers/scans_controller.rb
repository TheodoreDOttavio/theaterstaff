class ScansController < ApplicationController
  def index
    if !current_user.admin?
      redirect_to root_url
    end
  end


  def sort
  if current_user.admin?
    require 'fileutils'

    @lastperformanceid = 1
    @lastweek = (weekstart-14).strftime('%Y-%m-%d')
    @lastformat = 1

    #From a post, so move the file, and set the selections to save time
    #  is the post a newly uploaded file vs going through the images/ftp directory
    if params[:Data] then
      @thisfilename = params[:Data].original_filename
      @thisimage = params[:Data].tempfile
    else
      if params[:placeperformance] then
        myfile = "app/assets/images/" + params[:placefile].to_s
        myplacedfile = params[:placeperformance].to_s + "-" +
          params[:placeweek].to_s + "-" +
          params[:paperworkformat].to_s + ".jpg"
        myplacedpath = "app/assets/images/" +
          params[:placeweek].to_s.split("-").first + "/" +
          params[:placeperformance].to_s + "/"
        #@testertext = myfile + " moved to " + myplacedpath + myplacedfile

        #Create folders if needed and move the file
        FileUtils.mkdir_p myplacedpath
        FileUtils.mv myfile, myplacedpath + myplacedfile
        
        #record the new scan in the Scans db
        if params[:paperworkformat] == 1 then
          ss = true
        else
          ss = false
        end
        mondayarray = params[:placeweek].split("-")
        monday = DateTime.new(mondayarray[0].to_i, mondayarray[1].to_i, mondayarray[2].to_i)
        obj = Scan.new(performance_id: params[:placeperformance], monday: monday, specialservices: ss)
        obj.save

        #pass along the pull down variables for speedy entering...
        @lastperformanceid = params[:placeperformance]
        @lastweek = params[:placeweek]
        @lastformat = params[:paperworkformat]
      end
      #find the next image to sort:
      jpegfilelist = Dir.glob("app/assets/images/ftp/*.jpg")
      @thisimage = "ftp/" + jpegfilelist.first.split("/").last
    end

    #Performances
    @performances = Performance.select(:name, :id).order(:name)

    #Type of paperwork being uploaded
    @paperformat = []
    @paperformat.push(["Infrared Daily Log", 1])
    @paperformat.push(["Special Services Log ", 2])

    #Show a list of weeks going back 3 years:
    @completeweeks = Distributed.completeweeks(weekstart)
  else
    redirect_to root_url
  end
  end

end
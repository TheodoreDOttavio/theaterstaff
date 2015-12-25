class ScansController < ApplicationController
  def index
    if !current_user.admin?
      redirect_to root_url
    end
  end


  def sort
  if current_user.admin?
    @testertext = ""
    #From a post, so move the file, and set the selections to save time
    #  is the post a newly uploaded file vs going through the images/ftp directory
    if params[:Data] then
      @thisfilename = params[:Data].original_filename
      @thisimage = params[:Data].tempfile
    else
      if params[:placeperformance] then
        @testertext = params[:placeperformance].to_s + "-" + params[:placeweek].to_s + "-" + params[:paperworkformat].to_s
      end
      #find the next image to sort:
      jpegfilelist = Dir.glob("app/assets/images/ftp/*.jpg")
      @thisimage = "ftp/" + jpegfilelist.last.split("/").last
    end
    
    #Performances
    @performances = Performance.select(:name, :id).order(:name)

    #Type of paperwork being uploaded
    @paperworkformat = []
    @paperworkformat.push(["Infrared Daily Log",1])
    @paperworkformat.push(["Special Services Log ",2])

    #Show a list of weeks going back 3 years:
    @completeweeks = Distributed.completeweeks(weekstart)
  else
    redirect_to root_url
  end
  end

  def placeimage (thisimage, placeperformanceid, placeinweek, placeformat)
    
  end

end
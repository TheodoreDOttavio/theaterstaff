class ArchivesController < ApplicationController

  def backup
    #generate a list of data models to archive
    @datamodels = Array.new
    @datamodels.push(
      {"modelname" => "Distributed",
       "descriprion" => "Each product distributed"})
    @datamodels.push(
      {"modelname" => "Performance",
       "descriprion" => "List of shows and performances"})
    @datamodels.push(
      {"modelname" => "Cabinet",
       "descriprion" => "The inventory content of each console"})
    @datamodels.push(
      {"modelname" => "User",
       "descriprion" => "All Users-representatives and Administrators. Will not re-import!"})
    @datamodels.push(
      {"modelname" => "Available",
       "descriprion" => "User Availability"})
    @datamodels.push(
      {"modelname" => "Theater",
       "descriprion" => "All Venues. A list of Theaters"})
    @datamodels.push(
      {"modelname" => "Product",
       "descriprion" => "Inventory list - all products available"})

    #add the last time the model was changed
    @datamodels.map {|modelhash| modelhash.store("changed",
      eval(modelhash["modelname"]).pluck(:updated_at).last
      ) }

    @datamodels.map {|modelhash| modelhash.store("recordcount",
      eval(modelhash["modelname"]).count
      ) }

    # The YAML engine has to be rolled back to the old legacy syck instead of the newer Psych
    # The Psych engine randomly changes dates to a number lead by a * character
    #YAML::ENGINE.yamler = 'syck'
    #YAML::ENGINE.yamler = 'psych'
    #yeah... fuck all that noise. Going with good old boring CSV...
    require 'csv'
    mymodel = params[:mymodel]

    if mymodel then
      exportdata = eval(mymodel).order(:id)

      csv_string = CSV.generate do |mycsv|
        mycsv << eval(mymodel).attribute_names
        exportdata.each do |row|
          mycsv << row.attributes.values
        end
      end
    end

    respond_to do |f|
      f.html
      f.csv do
         send_data csv_string,
         type: "text/csv",
         filename: "#{mymodel}.csv"
      end
    end
  end


  def restore
    require 'csv'

    if params[:Data] == nil then
      flash[:error] = "No File found. Use the Browse button to select a File"
      redirect_to archives_backup_path
      return
    end

    uploaded_io = params[:Data]
    startcutoffdate = params[:startcutoff].to_date
    if startcutoffdate.nil? then
      startcutoffdate = DateTime.now - 10.years
    end
    
    endcutoffdate = params[:endcutoff].to_date
    if endcutoffdate.nil? then
      endcutoffdate = DateTime.now
    else
      #rename scans to make them available or unavailable by this cutoffdate
    end
    
    updateheroku = params[:updateheroku]
    if updateheroku.nil? then
      updateheroku = 0
    else
      updateheroku = 1
    end

    if !File.exist?(uploaded_io.tempfile) then
      flash[:error] = "File did not open!"
      @test = uploaded_io
      redirect_to archives_restore
      return
    end

    #Database Table/Model must match the filename
    mydatabase = uploaded_io.original_filename.split('.')[0]
    #correct file name for multile downloads that save as myfile(1).cvs
    mydatabase = mydatabase.split('(')[0]


    myfile = File.open(uploaded_io.tempfile)
    #Heroku needs to use #{RAILS_ROOT}/tmp/myfile_#{Process.pid} for file uploads
    #eval('string') converts the string to a class?!? well. it works...
    #also 'string'.constantize
    #found send('string')

    if params[:updateonly] == "1" then
      takeafter = eval(mydatabase).pluck(:updated_at).last
    else
      takeafter = nil
      eval(mydatabase).delete_all
    end

#    myyaml.each do |data|
#        eval(mydatabase).create(data.attributes)
#    end
    mycsv = CSV.parse(File.read(myfile), :headers => :first_row)
    mycsv.each do |data|
      myrowhash = data.to_hash
      myrowhash.delete(nil)
      if takeafter == nil then
        if updateheroku == 1 then
          if eval(mydatabase).count < 8000 then
            freshloading(myrowhash,startcutoffdate,endcutoffdate,mydatabase)
          end
        else
          freshloading(myrowhash,startcutoffdate,endcutoffdate,mydatabase)
        end
      else
        updateloading(myrowhash,startcutoffdate,takeafter,mydatabase)
      end
    end

    flash[:success] = " Data model #{mydatabase} has been re-loaded."
    redirect_to archives_backup_path
  end
end


def freshloading(myrowhash,startcutoffdate,endcutoffdate,mydatabase)
  if myrowhash.has_key? 'curtain' then
    if myrowhash['curtain'].to_date > startcutoffdate then
      if myrowhash['curtain'].to_date < endcutoffdate then
        eval(mydatabase).create(myrowhash)
      end
    end
  else
    eval(mydatabase).create(myrowhash)
  end
end


def updateloading(myrowhash,startcutoffdate,takeafter,mydatabase)
  if myrowhash['updated_at'].to_date > takeafter then
    if myrowhash.has_key? 'curtain' then
      if myrowhash['curtain'].to_date > startcutoffdate then
        myrecord = eval(mydatabase).find_by_id(myrowhash['id'])
        if myrecord != nil then
          myrecord.update(myrowhash)
        else
          eval(mydatabase).create(myrowhash)
        end
      end
    else
      myrecord = eval(mydatabase).find_by_id(myrowhash['id'])
      if myrecord != nil then
        myrecord.update(myrowhash)
      else
        eval(mydatabase).create(myrowhash)
      end
    end
  end
  
  
def scanrename(startcutoffdate)
  
end
  
end
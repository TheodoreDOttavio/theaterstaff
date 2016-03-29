class ArchivesController < ApplicationController

  def backup
    @archives = Archives.new

    mymodel = params[:mymodel]
    if mymodel then
      obj = eval(mymodel).order(:id)
      dataset = Array.new #otherwise Marshaling saves only the Active Record Relation Class (no datum!)
      obj.each do |row|
        dataset.push(row)
      end
      mydata = Marshal.dump(dataset)
    
      respond_to do |f|
        f.html
        f.csv do
          send_data mydata,
          type: "marshal",
          filename: "#{mymodel}"
        end
      end
      
    end

  end


def restore
  uploaded_io = params[:data]
  
  if uploaded_io == nil then
      flash[:error] = "No File found. Use the Browse button to select a File"
      redirect_to archives_backup_path
      return
    end
    
    if !File.exist?(uploaded_io.tempfile) then
      flash[:error] = "File did not open!"
      redirect_to archives_backup_path
      return
    else
      myfile = Marshal.load(File.open(uploaded_io.tempfile))
    
      #Database Table/Model must match the filename
      mydatabase = uploaded_io.original_filename.split('.')[0]
      # and correct the file name for multile downloads that save as myfile(1)
      mydatabase = mydatabase.split('(')[0]
      mycounter = 0
      
      #remove to 8k - A data cap for cloud sercvice. Also deletes existing data
      if !params[:updateheroku].nil? then
        #find existing count
        mytotal = 9900
        archives = Archives.new
        archives.datamodels.each do |thisdb|
          if mydatabase != thisdb["modelname"] then
            mytotal -= eval(thisdb["modelname"]).count
          end
        end
         if mytotal <= 1 then
           flash[:error] = "This database Already has more than 10,000 lines! No data changed. (#{mytotal})"
           redirect_to archives_backup_path
           return
         end
         
        if myfile.count >= mytotal then
          myfile = myfile[mytotal*-1,mytotal + 1]
          ActiveRecord::Base.transaction do
            eval(mydatabase).destroy_all
          end
        end

      end
      
      #Purge all data for a fresh reload
      if !params[:freshreload].nil? then
        ActiveRecord::Base.transaction do
          eval(mydatabase).destroy_all
        end
      end
    
      #@test = myfile[-2,3]
      #@testtwo = myfile.count

      ActiveRecord::Base.transaction do

      myfile.each do |row|
          if !eval(mydatabase).find_by(id: row.id) then
            incomeingrow = eval(mydatabase).new(row.as_json)
            incomeingrow.save
            mycounter += 1
          end
        end
      
    end


    flash[:success] = " Data model #{mydatabase} has loaded #{mycounter} records."
    redirect_to archives_backup_path
    end
end


  def oldrestore
    require 'csv'

    if params[:data] == nil then
      flash[:error] = "No File found. Use the Browse button to select a File"
      redirect_to archives_backup_path
      return
    end

    uploaded_io = params[:data]
    startcutoffdate = params[:startcutoff].to_date
    if startcutoffdate.nil? then
      startcutoffdate = DateTime.now - 10.years
    end

    endcutoffdate = params[:endcutoff].to_date
    if endcutoffdate.nil? then
      endcutoffdate = DateTime.now
    else
      #scanrename(endcutoffdate)
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
  end


  def xlsflatfile
    folder = "app/reports/"
    file = 'SA_distribution.xls'

    Xlsgenerator.new.cleanup(folder,file)
    Xlsgenerator.new.createflatfile(folder,file)

    send_file folder + file, filename: file,
      type: 'application/xls',
      disposition: 'attachment'
    end
  end

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
    #to create MS Excell files
    require 'fileutils'
    require 'rubygems'

    langlist = languagelist
    distributed = Distributed.order(:curtain, :eve, :performance_id, :product_id)

    folder = "app/reports/"
    file = 'SA_distribution.xls'

    #clean up... remove existing xls files
    FileUtils.rm Dir.glob(folder + file)

    workbook = WriteExcel.new(folder + file)
    worksheet  = workbook.add_worksheet

    # define formats for spreadsheet
    headerformat = workbook.add_format
    headerformat.set_font('Ariel')
    headerformat.set_size(11)
    headerformat.set_bold
    headerformat.set_color('black')
    headerformat.set_align('center')

    dataformat = workbook.add_format
    dataformat.set_font('Ariel')
    dataformat.set_size(11)
    dataformat.set_color('black')
    dataformat.set_align('left')

    numberformat = workbook.add_format
    numberformat.set_font('Ariel')
    numberformat.set_size(11)
    numberformat.set_color('black')
    numberformat.set_align('center')

    #set colums, row widths, and print settings
    worksheet.set_column('A:A', 21)
    worksheet.set_column('B:B', 30)
    worksheet.set_column('C:C', 11)
    worksheet.set_column('D:D', 4)
    worksheet.set_column('E:E', 17)
    worksheet.set_column('F:F', 4)
    worksheet.set_portrait
    worksheet.set_paper(1) # US letter size
    worksheet.center_horizontally

    #Write Headers
    worksheet.write(0, 0, "Theater", headerformat)
    worksheet.write(0, 1, "Performance", headerformat)
    worksheet.write(0, 2, "Device", headerformat)
    worksheet.write(0, 3, "QTY", headerformat)
    worksheet.write(0, 4, "Date", headerformat)
    worksheet.write(0, 5, "Shift", headerformat)

    distributed.each_with_index do |record, counter|
      worksheet.write(counter+1, 0, record.performance.theater.name, dataformat)
      worksheet.write(counter+1, 1, record.performance.name, dataformat)
      if record.product_id == 3 || record.product_id == 7 then
        worksheet.write(counter+1, 2, "Loop", dataformat)
      else
        worksheet.write(counter+1, 2, langlist.key(record.language), dataformat)
      end
      worksheet.write(counter+1, 3, record.quantity, numberformat)
      worksheet.write(counter+1, 4, record.curtain.strftime('%a %b %-d, %Y'), numberformat)
      if record.eve then
        worksheet.write(counter+1, 5, "Eve", dataformat)
      else
        worksheet.write(counter+1, 5, "Mat", dataformat)
      end
    end

    # write excell sheet to file
    workbook.close

    send_file folder + file, filename: file,
      type: 'application/xls',
      disposition: 'attachment'
  end
  end

class Xlsgenerator

  def initialize

  end


  def cleanup(folder,file)
    require 'fileutils'
    FileUtils.rm Dir.glob(folder + file)
  end


  def createflatfile(folder,file)
    #to create MS Excell files
    require 'fileutils'
    require 'rubygems'

    langlist = Shortlists.new.languages
    distributed = Distributed.order(:curtain, :eve, :performance_id, :product_id)

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
  end

end
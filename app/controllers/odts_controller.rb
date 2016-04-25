require 'rubygems'
require 'ruby-xslt'
require 'zip'

class OdtsController < ApplicationController
  unloadable
  layout "base"
  
  helper :attachments
  include AttachmentsHelper
  
  before_filter :find_project, :authorize, :only => :index
  
  def index
    # @odts = Odt.find(:all)
  end
  
  
  def upload
    st = odts_handle_file(params[:description], params[:filename])
    
    redirect_to :action => 'index',
                :project_id => Project.find(params[:project_id])
    flash[:notice] = "Uploaded file as '#{params[:description]}'"
    return
  end
  
  private

  
  def find_project
    @project = Project.find(params[:project_id])
  end

  
    

    
  # def my_handle_file(thetitle, filename)
  #   filenumber = 0
  #   Zip::File.open(filename) do |zip_file|
  #     zip_file.each do |entry|
  #       if zip_file == 'content.xml'
  #         content = entry.get_input_stream.read          
  #         # run xslt transformation to file
  #         str = my_xslt_transform(content, mypath)          
  #         # upload page content to wiki
  #         thepage = my_upload_to_wiki(thetitle, str)
  #       end
        
  #       if zip_file =~ /media/
  #         img = entry.get_input_stream.read
  #         my_upload_image(filenumber, entry.name, thepage, img)
  #       end
  #       if zip_file =~ /Pictures/
  #         img = entry.get_input_stream.read
  #         my_upload_image(filenumber, entry.name, thepage, zip_file)
  #       end
  #       filenumber = filenumber + 1
  #     end
      
  #     # MS -office   images
  #     #if File.exist?(mypath + "/media")
  #     #imagedir = Dir.new(mypath + "/media")
  #     #imagedir.each { |x| my_upload_image(thepage, mypath + "/media/" + x)}    
  #     #end
        
  #     # OpenOffice images
  #     #if File.exist?(mypath + "/Pictures")
  #     #imagedir = Dir.new(mypath + "/Pictures")
  #     #imagedir.each { |x| my_upload_image(thepage, mypath + "/Pictures/" + x)}
  #     #end
      
        
  #     #FileUtils.remove_dir(mypath)
  #   end
  #   return ""
  # end

    

  
  # def my_xslt_transform(xmlfile, path)
  #   result = "ERROR IN TRANSFORM"
  #   begin
  #     xsltfile = Rails.root.join("plugins/redmine_odts/conv1.xsl")
  #     tmpfile = "/tmp/xsltoutput.txt"
      
  #     # we trust here that it is executable
  #     if File.exists?("/usr/bin/xsltproc")
  #       xsltproc = "/usr/bin/xsltproc"
  #     elsif File.exists?("/opt/bitnami/common/bin/xsltproc")
  #       xsltproc = "/opt/bitnami/common/bin/xsltproc"
  #     end
      
  #     system(xsltproc + " -o #{tmpfile} #{xsltfile} #{xmlfile}")
      
  #   rescue Errno::ENOENT => msg
  #     f = File.new("/tmp/xslt-error.txt", "w")
  #     f.write( xsltproc + " -o #{tmpfile} #{xsltfile} #{xmlfile}\n\n")
  #     f.write(msg)
  #     f.close()
  #     flash[:error] = msg
  #   end
 
  #   result = IO.readlines(tmpfile)

  #   return result.to_s
  # end

#  def my_xslt_transform_rubyxslt(xmlcontent, path)
#    convfile = File.join(TEMPLATE_DIR, "conv1.xsl")
#    stylesheet = File.readlines(convfile.expandpath()).to_s
#    xms_doc = File.readlines(xmlcontent).to_s
#    
#    sheet = XSLT::Stylesheet.new(stylesheet, arguments)
#
#    str = ""
#    sheet.output [ str ]
#    sheet.apply(xml_doc)
#
#      f = File.new("/tmp/output.txt", "w")
#      f.write(msg)
#      f.close()
#
#
#    f = File.new("/tmp/output.txt", "w+")
#    sheet.apply(xml_doc, f)
#    f.close()
#  end




  
  # def deflate_content(filename)
  #   # setup a temporary path
  #   workdir = File.join(Dir.tmpdir, "odts-#{Time.now.to_i}")
  #   Dir.mkdir workdir
  #   realname = filename.path()

  #   # write entry to database, why bother?
  #   #    @file = Odt.new
  #   #    @file.filename = filename.original_filename
  #   #    @file.save
    
  #   # unzip to temporary path
  #   command = "/usr/bin/unzip #{realname} -d #{workdir}"
  #   success = system(command)
    
  #   success && $?.exitstatus == 0
  #   return workdir
  # end
  
end

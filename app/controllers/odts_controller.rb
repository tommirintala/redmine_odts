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
    st = my_handle_file(params[:description], params[:filename])
    
    redirect_to :action => 'index',
                :project_id => Project.find(params[:project_id])
    flash[:notice] = "Uploaded file as '#{params[:description]}'"
    return
  end
  
  private

  def odts_parse_odt_content(content)
    str = odts_handle_xslt_transform(content, "conv-odt.xsl")
  end
  
  def odts_parse_docx_content(content)
    str = odts_handle_xslt_transform(content, "conv-docx.xsl")
  end
    
  def find_project
    @project = Project.find(params[:project_id])
  end

  def odts_get_temp_dir
    @logger.info "get_temp_dir()"
    stamp = Time.now.to_i
    tmpname = "tom-#{stamp}"
    if !Dir.exists?(tmpname)
      @logger.info " create tmpdir: #{tmpname}"
      Dir.mkdir(tmpname)
    end
    return tmpname
  end
      
  def odts_handle_file(thetitle, filename)
    filenumber = 0
    tmpdir = otds_get_temp_dir
    if filename =~ /odt$/
      mode_odt = true
    else
      mode_odt = false
    end
    begin
      @logger.info " Got temporary dir location #{tmpdir}"
      Zip::File.open(filename) do |zip_file|
        @logger.info " open ZIP file: #{zip_file}"
        zip_file.each do |entry|
          @logger.info "  :begin handle file: '#{entry}'"
          t = entry.class
          @logger.info "   type = #{t}"
          
          if entry.name =~ /\.(jpg|png)/
            @logger.info "   IMAGE file"
          end
          # parse Images
          if entry.name =~ /(Pictures|media\/)/
            @logger.info "   is image"
            img = entry.get_input_stream.read
            my_upload_image(filenumber, entry.name, page, img)
            #else
            #@logger.info "   not image"
          end
          
          if entry.name =~ /(content.xml|document.xml)/
            content = entry.get_input_stream.read
            outname = "#{tmpdir}/content.xml"
            o = File.new(outname, "w")
            o.puts(content)
            o.close()
            
            if mode_odt          # odt document
              wikicontent = my_parse_odt_content(outname)
            else                 # docx document
              wikicontent = my_parse_docx_content(outname)
            end
            my_upload_to_wiki(page, wikicontent)
          end
          
          filenumber = filenumber + 1
          @logger.info "  .end of '#{entry}'\n"
        end
      end
    rescue
      # error?
    end  
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

    
  def my_upload_image(no, name, page, x)
    # if it is a directory, return
    
    #if File.directory?(x)
    #  return ""
    #end
    
    tmpfile = "upload-#{no}-#{Time.now.to_i}.tmp"
    
    af = ActionController::UploadedTempfile.new(tmpfile)
    af.binmode
    af.write(x)
    #af.original_path = x
    
    if File.fnmatch?('*.png', name)
      af.content_type = "image/png"
    elsif File.fnmatch?('.tif', name)
      af.content_type = 'image/tif'
    elsif File.fnmatch?('.jpg', name)
      af.content_type = "image/jpeg"
    else
      content_type = 'application/binary'
    end
    
    af.rewind

    att = Attachment.create(
      :container => page,
      :file => af,
      :description => "autoloaded image",
      :author => User.current  )
    
    af.unlink
  end
  
  def my_xslt_transform(bodyfile, xslfile)
    @logger.info "handle_xslt_transform()"
    @logger.info "  using xml: '#{bodyfile}'"
    @logger.info "  using xsl: '#{xslfile}'"
    begin
      XML::XSLT.registerErrorHandler {|string| puts string}
      xslt = XML::XSLT.new()
      xslt.xml = bodyfile
      xslt.xsl = xslfile
      #xslt.save("output.rdoc")
      result = xslt.serve()
    rescue Errno::ENOENT => msg
      flash[:error] = msg
    end
    
    #print result.to_s
    return result.to_s
  end

  
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



  def my_upload_to_wiki(title, wikicontent)
    page_title = title
    page_title ||= "odts-#{Time.now.to_i}"
    project = Project.find(params[:project_id])
    #    wiki = project.wiki
    @auto_page = project.wiki.find_or_new_page(page_title)
    @auto_page.content = WikiContent.new(:text => wikicontent.to_s, 
					 :comments => "added by automate",
					 :author  => User.current)
    
    @auto_page.save
    return @auto_page
  end


  
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

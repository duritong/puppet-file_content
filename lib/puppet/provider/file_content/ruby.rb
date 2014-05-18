Puppet::Type.type(:file_content).provide(:ruby) do
  def exists?
    target_content.include?(source_content)
  end

  def create
    File.open(resource[:path],'a') do |f|
      f << "\n" if !target_content.empty? && target_content[-1] != "\n"
      f << ((source_content[-1] == "\n") ? source_content : "#{source_content}\n")
    end

  end

  def destroy
    output = target_content.gsub("#{source_content}\n",'').gsub(source_content,'')
    File.open(resource[:path],'w') {|f| f << output }
  end

  private

  def source_content
    @source_content ||= (resource[:content] || File.read(resource[:source]))
  end

  def target_content
    @target_content ||= (File.exists?(resource[:path]) ? File.read(resource[:path]) : '')
  end

end

#!/bin/env ruby


def usage(msg = nil)
  puts "\nERROR: #{msg}\n\n" if msg
  puts <<END
Usage: #{$0} present target-file source-file
         -> ensures if whole content of source-file exists in target-file
       #{$0} absent target-file source-file
         -> ensures that the content of source-file doesn't exist in target-file
       #{$0} check target-file source-file
         -> checks wether a content is part not
END
  exit 1
end

usage if ARGV.length != 3

action = ARGV.shift

usage("No such action #{action}") unless ['absent','present','check'].include?(action)

target_file = ARGV.shift
source_file = ARGV.shift

usage("#{target_file} does not exist") if !File.exists?(target_file) && action == 'absent'
usage("#{source_file} does not exist") unless File.exists?(source_file)

target_content = File.exists?(target_file) ? File.read(target_file) : ''
source_content = File.read(source_file)
raise "Empty source file, makes not sense to manage it" if source_content.empty?

content_exists = target_content.include?(source_content)

if action == 'present' && !content_exists
  File.open(target_file,'a') do |f|
    f << "\n" if !target_content.empty? && target_content[-1] != "\n"
    f << (source_content[-1] == "\n") ? source_content : "#{source_content}\n"
  end
elsif action == 'absent' && content_exists
  output = target_content.sub("#{source_content}\n",'').sub(source_content,'')
  File.open(target_file,'w') { |f| f << output }
elsif action == 'check'
  exit content_exists ? 0 : 1
end

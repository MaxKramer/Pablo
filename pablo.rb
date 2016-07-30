require 'optparse'
require 'xcodeproj'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end

opts.on("-p", "--project Project" "Path to xcodeproj") do |v|
    options[:project] = v
  end

end.parse!

class Pablo

	@project_path
	@project
	@swift_files
	def initialize(project)
		@project_path = File.expand_path(project)

		unless File.exists? @project_path
			raise "#{path} does not exist."
		end

		@project = Xcodeproj::Project.open(@project_path)

		target = @project.targets.first

		puts "Using #{target} as the main target"

		files = target.source_build_phase.files.to_a
		
		files = files.reject{ |i| i.file_ref.class != Xcodeproj::Project::Object::PBXFileReference }
		files = files.map do |pbx_build_file|
			{
		    	:path => pbx_build_file.file_ref.real_path.to_s,
		    	:name => pbx_build_file.file_ref.display_name
			}
		end.select do |hash|
		  hash[:path].end_with?(".swift") && File.exists?(hash[:path])
		end

		localizable_strings = {}

		files.each do |hash|
			matches = File.read(hash[:path]).scan(/NSLocalizedString\((.+?),\s?comment:\s?(.+?)"\)/)
			unless matches.count == 0
				path = hash[:path]
				localizable_strings[path] = matches 
			end
		end

		lines = []

		localizable_strings.each do |path, matches|
			matches.each do |key, comment|
				key = key.gsub("\"", "")
				comment = comment.gsub("\"", "")
				lines.append "/*\n\tComment: \"#{comment}\"\n\tFile: #{path}\n*/"
				lines.append "\t\"#{key}\" = \"#{key}\";\n"
			end
		end

		puts lines.join("\n")
	end
end

instance = Pablo.new options[:project]
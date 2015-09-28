# -*- coding: utf-8 -*-
=begin
	$ bundle exec ruby app/ldi.rb {files}

=end

require "active_record"
require "mysql2"
require "fileutils"

# DB connection
ActiveRecord::Base.establish_connection(
	adapter:  "mysql2",
	host:     "localhost",
	username: "shadocman",
	password: "shadoc01",
	database: "shadocdb"
)

class Location < ActiveRecord::Base
end

class LocationDataImporter
	attr_accessor :location, :key_line, :file_path, :registered_on, :backupdir
	def initialize
		@backupdir = "./ldi_backup"
		Dir.mkdir(@backupdir) unless Dir.exist?(@backupdir)
	end

	def parse file
		lines = []
		File.readlines(file).each do |line|
			line.strip!
			line.gsub(/[A-z]{2,2}\s(.+)\s[A-z]{2,2}/){
				@location = $1.gsub(/\s/,"").strip.upcase
				@location = @location.gsub(/-I/,"-1")
			}
			line.gsub!(/\t+/,"\s")
			lines.push(line)
		end
		@key_line = lines[0,10].join("\s")
		@file_path = file
		filename = File.basename(file)
		@registered_on = Date.new(filename[0,4].to_i, filename[4,2].to_i, filename[6,2].to_i)
		@key_line.size
	end

	def import
		if @location
			new_loc = Location.new(
				:location_code => @location,
				:keywords => @key_line,
				:registered_on => @registered_on,
				:file_path => @file_path
			)	
			unless new_loc.save
				$stderr.print "mysql error\n"
			end
		end
	end

	def backup(file)
		backupfile = @backupdir + '/' + File.basename(file) + '.bak'
		FileUtils.mv(file,backupfile)
	end
end

if __FILE__ == $0
	ldi = LocationDataImporter.new
	ARGV.each do |file|
		next unless File.exist?(file)
		if ldi.parse(file)
			begin
				ldi.import
			rescue
				$stderr.print $_
			end
			ldi.backup(file)
		end
	end
end

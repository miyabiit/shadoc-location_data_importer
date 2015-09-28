@ECHO OFF
SET RUBY_BIN=%C:\ruby\Ruby22-x64\bin%
SET PATH=%RUBY_BIN%;%PATH%
cd c:\github\shadoc-location_data_importer
bundle exec ruby -Eutf-8 app\ldi.rb c:\shadoc\20*.txt
pause
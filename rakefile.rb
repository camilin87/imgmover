task :default => [:move_folder_debug]

def basedir
   return File.expand_path "."
end

task :move_folder_debug do
    puts "moving folders DEBUG"
    puts basedir
end

task :move_folders do
    puts "moving folders"
end

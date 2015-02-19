task :default => [:move_folder_debug]

def basedir
   return File.expand_path "."
end

task :move_folder_debug do
    move_folders_internal(true)
end

task :move_folders do
    move_folders_internal()
end

def move_folders_internal(is_debug=false)
    environment = is_debug ? "DEBUG" : ""
    puts "moving folders #{environment}"
    puts basedir

    for dirname in get_subdirs(basedir) do
        if not should_ignore_directory(dirname)
            puts dirname
        end
    end
end

def get_subdirs(parent_dir)
    return Dir.entries(parent_dir).select { |entry|
        File.directory? entry and !(entry =='.' || entry == '..') 
    }
end

def should_ignore_directory(directory_name)
    return directory_name.start_with?("_")
end

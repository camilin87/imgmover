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

    for dirname in get_subdirs_to_analyze(basedir) do
        full_dir_path = get_full_path dirname

        for filename in get_filenames full_dir_path do
            if not should_ignore_file filename
                puts "... #{filename}"

                exif_raw_data = read_exif filename
                year = extract_year exif_raw_data

                if year.length > 0
                    dest_folder = get_year_folder year
                    create_folder_if_needed dest_folder, is_debug
                    move_folder full_dir_path, dest_folder, is_debug
                    break
                end
            end
        end
    end
end

def get_subdirs_to_analyze(parent_dir)
    return get_subdirs(parent_dir).select { |dirname|
        not should_ignore_directory dirname
    }
end

def get_subdirs(parent_dir)
    return Dir.entries(parent_dir).select { |entry|
        File.directory? entry and !(entry =='.' || entry == '..') 
    }
end

def should_ignore_directory(directory_name)
    return directory_name.start_with?("_")
end

def should_ignore_file(filename)
    for ext in [".mov", ".png"] do
        if filename.downcase.end_with? ext
            return true
        end
    end
    return false
end

def get_full_path(directory_name)
    return File.join(basedir, directory_name)
end

def get_filenames(parent_dir)
    return Dir["#{parent_dir}/*.*"]
end

def standardize_filename(full_path)
    for c in [' ', '(', ')', '\''] do
        full_path.gsub!("#{c}"){"\\#{c}"}
    end
    return full_path
end

def read_exif(filename)
    std_filename = standardize_filename filename                    
    return `exiftool #{std_filename}`
end

def extract_year(exif_raw_data)
    original_time_arr = exif_raw_data.split(/(\n)/).delete_if{ |l|
        not l.include? "Date/Time Original" 
    }

    if original_time_arr.size == 0
        return ""
    else
        return extract_year_from_time_str original_time_arr[0]
    end
end

def extract_year_from_time_str(exif_time_line)
    # Date/Time Original              : 2013:09:25 19:36:11.598
    return exif_time_line.split(/(:)/)[2].strip
end

def get_year_folder(year)
    return File.join(basedir, "_#{year}/")
end

def create_folder_if_needed(dir_full_path, is_debug)
    if not Dir.exists? dir_full_path
        puts "mkdir #{dir_full_path}"
        if not is_debug
            mkdir dir_full_path
        end
    end
end

def move_folder(source_path, dest_path, is_debug)
    std_source = standardize_filename source_path
    std_dest = standardize_filename dest_path

    move_command = "mv -v #{std_source} #{std_dest}"
    puts move_command

    if not is_debug
        sh move_command
    end
end

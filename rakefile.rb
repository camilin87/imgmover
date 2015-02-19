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
        if not should_ignore_directory dirname
            full_dir_path = get_full_path dirname

            for filename in get_filenames full_dir_path do
                if not should_ignore_file filename
                    puts "Analyzing #{filename}"

                    exif_raw_data = read_exif filename
                    year = extract_year exif_raw_data

                    puts year

                    if year.length > 0
                        puts "moving folder to _#{year}"

                        break
                    end
                else
                    puts "Skipping #{filename}"
                end
            end

            # puts full_dir_path
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
    # puts original_time_arr

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

task :ensure_bare do
  next if Dir.exist?("/Volumes/PI2CLUSTER")
  fail "SD card must be set up and mounted properly."\
    "  Expected to find `/Volumes/PI2CLUSTER`."
end

task :ensure_raspbian do
  DEST_DIR="/Volumes/boot"
  next if Dir.exist?(DEST_DIR)
  fail "SD card must be set up and mounted properly."\
    "  Expected to find `#{DEST_DIR}`."

end

task :ensure_ubuntu do
  DEST_DIR="/Volumes/system-boot"
  next if Dir.exist?("/Volumes/system-boot")
  fail "SD card must be set up and mounted properly."\
    "  Expected to find `/Volumes/system-boot`."
end


namespace :sd do
  desc "Reformat the SD card specified via DEVICE, and prepare it for `init`."
  task :format do
    device = ENV.fetch("DEVICE")
    sh "diskutil partitionDisk #{device} 1 MBR MS-DOS PI2CLUSTER 100%"
  end

  desc "Initialize a bare SD card with NOOBS."
  task init: [:ensure_bare] do
    cp_r FileList["image/current/*"], "/Volumes/PI2CLUSTER/"
  end

  desc "Remove cruft from SD card."
  task clean: [:ensure_ubuntu] do
    rm_f FileList["#{DEST_DIR}/.fseventsd"]
    rm_f FileList["#{DEST_DIR}/.Spotlight*"]
    rm_f FileList["#{DEST_DIR}/.Trash"]
    rm_f FileList["#{DEST_DIR}/._.Trash"]
  end

  desc "Remove setup files and other cruft from SD card."
  task remove: [:ensure_ubuntu, :'sd:clean'] do
    rm_f FileList["#{DEST_DIR}/pi2cluster/**/*"]
  end

  desc "Copy setup files to boot volume of SD card."
  task copy: [:ensure_ubuntu, :'sd:remove'] do
    mkdir_p "#{DEST_DIR}/pi2cluster"
    cp_r FileList["boot/*"], "#{DEST_DIR}/"
  end

  desc "Eject the SD card."
  task eject: [:ensure_ubuntu, :'sd:clean'] do
    sh "diskutil eject #{DEST_DIR}"
  end
end


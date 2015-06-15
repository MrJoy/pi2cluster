task :ensure_bare do
  next if Dir.exist?("/Volumes/PI2CLUSTER")
  fail "SD card must be set up and mounted properly."\
    "  Expected to find `/Volumes/PI2CLUSTER`."
end

task :ensure_raspbian do
  next if Dir.exist?("/Volumes/boot")
  fail "SD card must be set up and mounted properly."\
    "  Expected to find `/Volumes/boot`."
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
  task clean: [:ensure_raspbian] do
    rm_f FileList["/Volumes/boot/.fseventsd"]
    rm_f FileList["/Volumes/boot/.Spotlight*"]
    rm_f FileList["/Volumes/boot/.Trash"]
    rm_f FileList["/Volumes/boot/._.Trash"]
  end

  desc "Remove setup files and other cruft from SD card."
  task remove: [:ensure_raspbian, :'sd:clean'] do
    rm_f FileList["/Volumes/boot/pi2cluster/**/*"]
  end

  desc "Copy setup files to boot volume of SD card."
  task copy: [:'sd:remove'] do
    mkdir_p "/Volumes/boot/pi2cluster"
    cp_r FileList["boot/*"], "/Volumes/boot/"
  end

  desc "Eject the SD card."
  task eject: [:'sd:clean'] do
    sh "diskutil eject /Volumes/boot/"
  end
end


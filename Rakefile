COPY_SIZE       = "16m"
POSSIBLE_MOUNTS = ["/Volumes/system-boot",
                   "/Volumes/boot",
                   "/Volumes/EXTRASPACE",
                   "/Volumes/PI2CLUSTER"]

# def device(fallback)
#   disk_info = JSON.load(`diskutil list -plist | plutil -convert json -r - -o -`)

#   device    = disk_info["AllDisksAndPartitions"]
#               .select { |disk| disk["Content"] == "FDisk_partition_scheme" }
#               .select { |disk| disk["Partitions"] .find { |part| part["Content"] == "Windows_FAT_32"} }
#               .first["DeviceIdentifier"]
#   device    = fallback unless device =~ /\Adisk\d+\z/
#   fail "Couldn't find mounted MMC device!" unless device
#   return "/dev/r#{device}"
# end

task :ensure_device do
  mount_point = POSSIBLE_MOUNTS.find { |name| Dir.exist?(name) }
  fail "SD card must be set up and mounted properly." \
    "  Expected to find something from POSSIBLE_MOUNTS list." unless mount_point
  DEST_DIR=mount_point
end

namespace :ubuntu do
  desc "Write the Snappy Core Ubuntu image to DEVICE (/dev/rdiskX).  Requires `sudo`!"
  task :init do
    device = ENV.fetch("DEVICE")
    ASSET_DIR = "image/snappy-15.04"
    # begin
      sh "time sudo dd if=#{ASSET_DIR}/ubuntu-15.04-snappy-armhf-raspi2.img of=#{device} bs=#{COPY_SIZE}"
    # rescue StandardError
    #   # dd returns a non-zero status code after giving a message like the one that follows!  Despite
    #   # this, all seems to work fine.  Ew!
    #   #   dd: /dev/rdisk4: Invalid argument
    # end
    sleep 10
  end
end

namespace :sd do
  desc "Remove cruft from SD card."
  task clean: [:ensure_device] do
    sh "mdutil -i off #{DEST_DIR}"
    rm_f FileList["#{DEST_DIR}/.fseventsd"]
    rm_f FileList["#{DEST_DIR}/.Spotlight*"]
    rm_f FileList["#{DEST_DIR}/.Trash"]
    rm_f FileList["#{DEST_DIR}/._.Trash"]
  end

  desc "Remove setup files and other cruft from SD card."
  task remove: [:ensure_device] do
    rm_f FileList["#{DEST_DIR}/pi2cluster/**/*"]
  end

  desc "Copy setup files to boot volume of SD card."
  task copy: [:ensure_device, :remove] do
    sh "cp #{ASSET_DIR}/uEnv.txt #{DEST_DIR}/"
    mkdir_p "#{DEST_DIR}/pi2cluster"
    cp_r FileList["boot/*"], "#{DEST_DIR}/"
  end

  desc "Eject the SD card."
  task eject: [:ensure_device, :clean] do
    sh "diskutil eject #{DEST_DIR}"
  end

  desc "Unmount, but do not eject, the SD card specified by DEVICE (/dev/rdiskX)."
  task :unmount do
    sh "diskutil unmountDisk #{ENV.fetch("DEVICE")}"
  end
end

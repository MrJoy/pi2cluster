POSSIBLE_MOUNTS = ["/Volumes/system-boot",
                   "/Volumes/boot",
                   "/Volumes/EXTRASPACE",
                   "/Volumes/PI2CLUSTER"]
def device(fallback)
  disk_info = JSON.load(`diskutil list -plist | plutil -convert json -r - -o -`)

  device    = disk_info["AllDisksAndPartitions"]
              .select { |disk| disk["Content"] == "FDisk_partition_scheme" }
              .select { |disk| disk["Partitions"] .find { |part| part["Content"] == "Windows_FAT_32"} }
              .first["DeviceIdentifier"]
  device    = fallback unless device =~ /\Adisk\d+\z/
  fail "Couldn't find mounted MMC device!" unless device
  return "/dev/r#{device}"
end

task :ensure_device do
  mount_point = POSSIBLE_MOUNTS.find { |name| Dir.exist?(name) }
  fail "SD card must be set up and mounted properly."\
    "  Expected to find something from POSSIBLE_MOUNTS list." unless mount_point
  DEST_DIR=mount_point
end

COPY_SIZE="16m"
namespace :ubuntu do
  desc "Write the Snappy Core Ubuntu image to DEVICE (/dev/rdiskX).  Requires `sudo`!"
  task :init do
    device = ENV.fetch("DEVICE")
    begin
      sh "time sudo dd if=image/snappy-15.04/ubuntu-15.04-snappy-armhf-rpi2.img of=#{device} bs=#{COPY_SIZE}"
    rescue StandardError
      # dd returns a non-zero status code!  Ew!
    end
    sleep 10
  end
end

# namespace :noobs do
#   desc "Reformat the SD card specified via DEVICE (/dev/rdiskX), and prepare it for `init`."
#   task :format do
#     device = ENV.fetch("DEVICE")
#     sh "diskutil partitionDisk #{device} 1 MBR MS-DOS PI2CLUSTER 100%"
#   end

#   desc "Initialize a bare SD card with NOOBS."
#   task init: [:ensure_bare] do
#     cp_r FileList["image/current/*"], "/Volumes/PI2CLUSTER/"
#   end
# end


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
    sh "cp image/snappy-15.04/uEnv.txt #{DEST_DIR}/"
    mkdir_p "#{DEST_DIR}/pi2cluster"
    cp_r FileList["boot/*"], "#{DEST_DIR}/"
  end

  desc "Eject the SD card."
  task eject: [:ensure_device, :clean] do
    sh "diskutil eject #{DEST_DIR}"
  end

  desc "Unmount, but do not eject, the SD card."
  task :unmount do
    target  = POSSIBLE_MOUNTS.find { |path| Dir.exist?(path) }
    next unless target
    sh "diskutil unmountDisk #{target}"
  end
end

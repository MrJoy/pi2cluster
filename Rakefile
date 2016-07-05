# Adding New Platforms:
# 1. Update `README.md` with download URL, destination in `images/`, login info, etc.
# 2. Set up assets under `boot/`.  Currently `common/bin/setup.sh` assumes systemd and I'm punting
#    on that for now!
# 3. Add the FAT32 volume name for the new image to `POSSIBLE_MOUNTS`.
# 4. Add an appropriate `<os>:init` task, based on the ones below.

COPY_SIZE       = "16m".freeze
POSSIBLE_MOUNTS = ["/Volumes/system-boot",
                   "/Volumes/boot",
                   "/Volumes/EXTRASPACE",
                   "/Volumes/PI2CLUSTER",
                   "/Volumes/HypriotOS"].freeze
CONFIG          = Hash.new { |_hsh, key| raise "Couldn't find `#{key}` in CONFIG!" }

def device; CONFIG[:device] ||= ENV.fetch("DEVICE"); end

task :ensure_device do
  mount_point = POSSIBLE_MOUNTS.find { |name| Dir.exist?(name) }
  raise "SD card must be set up and mounted properly." \
        "  Expected to find something from POSSIBLE_MOUNTS list." unless mount_point
  CONFIG[:destination] = mount_point
end

namespace :ubuntu do
  desc "Write the Snappy Core Ubuntu image to DEVICE (/dev/rdiskX).  Requires `sudo`!"
  task :init do
    CONFIG[:platform]         = "snappy-15.04"
    CONFIG[:image]            = "image/snappy-15.04/ubuntu-15.04-snappy-armhf-raspi2.img"
    sh "time sudo dd if=#{CONFIG[:image]} of=#{device} bs=#{COPY_SIZE}"
    sleep 10 # TODO: Wait for mount in a more intelligent way!
  end
end

namespace :hypriotos do
  desc "Write the HypriotOS image to DEVICE (/dev/rdiskX).  Requires `sudo`!"
  task :init do
    CONFIG[:platform]         = "hypriotos-0.8.0"
    CONFIG[:image]            = "image/hypriotos-0.8.0/hypriotos-rpi-v0.8.0.img"
    sh "time sudo dd if=#{CONFIG[:image]} of=#{device} bs=#{COPY_SIZE}"
    sleep 10 # TODO: Wait for mount in a more intelligent way!
  end
end

namespace :sd do
  desc "Remove cruft from SD card."
  task clean: [:ensure_device] do
    sh "mdutil -i off #{CONFIG[:destination]}"
    rm_f FileList["#{CONFIG[:destination]}/.fseventsd"]
    rm_f FileList["#{CONFIG[:destination]}/.Spotlight*"]
    rm_f FileList["#{CONFIG[:destination]}/.Trash"]
    rm_f FileList["#{CONFIG[:destination]}/._.Trash"]
  end

  desc "Remove setup files and other cruft from SD card."
  task remove: [:ensure_device] do
    rm_f FileList["#{CONFIG[:destination]}/pi2cluster/**/*"]
  end

  desc "Copy setup files to boot volume of SD card."
  task copy: [:ensure_device, :remove] do
    target = "#{CONFIG[:destination]}/pi2cluster"
    if Dir.exist?(target)
      CONFIG[:platform] = File.read("#{target}/.platform").strip
    else
      mkdir_p target
    end
    sh "rsync -av boot/common/ #{target}/"
    sh "rsync -av boot/#{CONFIG[:platform]}/ #{target}/"
    File.write("#{target}/.platform", CONFIG[:platform])
  end

  desc "Eject the SD card."
  task eject: [:ensure_device, :clean] do
    sh "diskutil eject #{CONFIG[:destination]}"
  end

  desc "Unmount, but do not eject, the SD card specified by DEVICE (/dev/rdiskX)."
  task :unmount do
    # TODO: Ensure it's not already unmounted!
    CONFIG[:device] = ENV.fetch("DEVICE")
    sh "diskutil unmountDisk #{CONFIG[:device]}"
  end
end

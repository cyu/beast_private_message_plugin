vendor_dir = File.join(RAILS_ROOT, 'vendor')

default_views_dir = File.join(vendor_dir, 'plugins', 'private_message', 'views')
target_dir = File.join(vendor_dir, 'beast', 'private_message')

FileUtils.mkdir_p target_dir
FileUtils.cp_r default_views_dir, target_dir

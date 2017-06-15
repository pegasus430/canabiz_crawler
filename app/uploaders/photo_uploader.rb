# encoding: utf-8

class PhotoUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick
  include CarrierWave::ImageOptimizer
  include Sprockets::Rails::Helper
  
  process :optimize
  
  storage :fog #fog connects application and AWS
  
  #make the file name unique
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
  
  
  #make different sizes of the file
  version :tiny do 
    process :resize_to_fill => [20,20]
  end
  
  version :profile_size do 
    process :resize_to_fill => [420, 230]
  end
  
  #specifies the file types we can take
  #if we wanted file upload we would use different file sizes
  def extension_white_list
    %w(jpg jpeg gif png)
  end
  
  
end

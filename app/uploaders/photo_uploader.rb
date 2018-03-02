# encoding: utf-8

class PhotoUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick #adds ability to resize images
  include CarrierWave::ImageOptimizer
  include Sprockets::Rails::Helper
  
  process :optimize
  
  storage :fog #fog connects application and AWS
  
  #where to store the image
  def store_dir
      "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
  
  
  #make different sizes of the file
  version :tiny do 
    process :resize_to_fill => [20,20]
  end
  
  #article sizes
  version :profile_size do 
    process :resize_to_fill => [420, 230]
  end
  
  version :trending_size do 
    process :resize_to_fill => [280, 350]
  end
  
  #product sizes
  version :product_show do 
    process :resize_to_fill => [425, 425]
  end
  
  version :product_show_smaller do 
    process :resize_to_fill => [425, 250]
  end
  
  version :product_side_list do 
    process :resize_to_fill => [150, 80]
  end
  
  version :product_dispensary_index do 
    process :resize_to_fill => [223, 223]
  end
  
  #dispensary sizes
  version :dispensary_show do 
    process :resize_to_fill => [425, 350]
  end
  
  #specifies the file types we can take
  #if we wanted file upload we would use different file sizes
  def extension_white_list
    %w(jpg jpeg gif png)
  end
  
  
end

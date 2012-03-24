# encoding: utf-8

class GroupCoverUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  process convert: 'PNG'
  process resize_to_fit: [260, 94]

  version :thumb do
    process resize_to_fit: [260, 94]
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def filename
    "#{original_filename}.png" if original_filename
  end
end

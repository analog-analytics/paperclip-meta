require 'spec_helper'
require 'paperclip-meta/process_meta_service'

describe "ProcessMetaService" do

  before do
    Image.delete_all
    ImageWithNoValidation.delete_all
    @service = Paperclip::Meta::ProcessMetaService.new
    @images = [ Image.create!(small_image: small_image),
                Image.create!(small_image: small_image, big_image: big_image),
                Image.create! ]
    Image.update_all(small_image_meta: nil, big_image_meta: nil)
  end

  it 'reprocesses all the attachments meta data' do
    images = Image.where('small_image_meta is not null or big_image_meta is not null')
    assert_equal 0, images.count

    @service.process!(Image)

    assert_equal 2, images.count
    assert_equal(small_image_meta, images.first.small_image.meta_data)
    assert_equal(small_image_meta, images.last.small_image.meta_data)
    assert_equal(big_image_meta, images.last.big_image.meta_data)
  end

  private

  def small_path
    File.join(File.dirname(__FILE__), 'fixtures', 'small.png')
  end

  # 50x64
  def small_image
    File.open(small_path)
  end

  def small_image_meta
    { original: { width: 50,
                  height: 64,
                  size: 6646,
                  fingerprint: "9c0a079bdd7701d7e729bd956823d153" }}
  end

  def big_image_meta
    { thumb: { width: 100,
               height: 100,
               size: 3475,
               fingerprint: "b5ca2374a6cd89c4a971ddeb71f6f86d"},
      large: { width: 500,
               height: 500,
               size: 37801,
               fingerprint: "f2e4b93cb207a29fdb5ca23bfda3a599"},
      original: { width: 600,
                  height: 277,
                  size: 37042,
                  fingerprint: "3b26372629ef054dd31f02cb0c6d64b0"}}
  end

  def geometry_for(path)
    Paperclip::Geometry.from_file(path)
  end

  def fingerprint_for(path)
    Digest::MD5.file(path).hexdigest
  end

  # 600x277
  def big_image
    File.open(File.join(File.dirname(__FILE__), 'fixtures', 'big.jpg'))
  end

  def not_image
    File.open(File.join(File.dirname(__FILE__), 'fixtures', 'big.zip'))
  end
end

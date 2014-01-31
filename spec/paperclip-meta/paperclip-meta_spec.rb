require 'spec_helper'

describe "Attachment" do
  it "saves image geometry for original image" do
    img = Image.new
    img.small_image = small_image
    img.save!

    img.reload

    geometry = small_geometry
    img.small_image.width eq(geometry.width)
    img.small_image.height eq(geometry.height)
  end

  it "saves geometry for styles" do
    img = Image.new
    img.small_image = small_image
    img.big_image = big_image
    img.save!

    img.big_image.width(:small).should == 100
    img.big_image.height(:small).should == 100
  end

  describe 'file size' do
    before do
      @image = Image.create(big_image: big_image)
    end

    it 'should save file size with meta data ' do
      path = File.join(File.dirname(__FILE__), "../tmp/fixtures/tmp/small/#{@image.id}.jpg")
      size = File.stat(path).size
      @image.big_image.size(:small).should == size
    end

    it 'should access normal paperclip method when no style passed' do
      @image.big_image.should_receive(:size_without_meta_data).once.and_return(1234)
      @image.big_image.size.should == 1234
    end

    it 'should have access to original file size' do
      @image.big_image.size.should == 37042
    end
  end

  it "clears geometry fields when image is destroyed" do
    img = Image.create(small_image: small_image, big_image: big_image)
    img.big_image.width(:small).should == 100

    img.big_image = nil
    img.save!

    img.big_image.width(:small).should be_nil
  end

  it "does not fails when file is not an image" do
    img = Image.new
    img.small_image = not_image
    -> { img.save! }.should_not raise_error
    img.small_image.width(:small).should be_nil
  end

  private

  def small_path
    File.join(File.dirname(__FILE__), '..', 'fixtures', 'small.png')
  end

  def small_image
    File.open(small_path)
  end

  def small_geometry
    Paperclip::Geometry.from_file(small_path)
  end

  def big_image
    File.open(File.join(File.dirname(__FILE__), '..', 'fixtures', 'big.jpg'))
  end

  def not_image
    File.open(File.join(File.dirname(__FILE__), '..', 'fixtures', 'big.zip'))
  end
end

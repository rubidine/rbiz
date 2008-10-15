gem(defined?(JRUBY_VERSION) ? 'rmagick4j' : 'rmagick')
require 'RMagick'

module ProductImageHandler

  require 'fileutils'

  def thumbnail fd
    rv = nil
    i = Magick::Image.from_blob(fd).first
    ow, oh = i.columns, i.rows
    cw = CartConfig.get(:thumbnail_width, :image)
    ch = CartConfig.get(:thumbnail_height, :image)
    wp = ow.to_f / cw.to_f
    hp = oh.to_f / ch.to_f
    if CartConfig.get(:thumbnail_exact_dimensions, :image)
      rv = i.resize(cw, ch)
    elsif wp > 1.0 or hp > 1.0
      mx = [wp, hp].max
      rv = i.resize((ow/mx).round, (oh/mx).round)
    else
      rv = i
    end
    rv
  end

  def fullsize fd
    rv = nil
    i = Magick::Image.from_blob(fd).first
    ow, oh = i.columns, i.rows
    cw = CartConfig.get(:width, :image)
    ch = CartConfig.get(:height, :image)
    wp = ow.to_f / cw.to_f
    hp = oh.to_f / ch.to_f
    if CartConfig.get(:exact_dimensions, :image)
      rv = i.resize(cw, ch)
    elsif wp > 1.0 or hp > 1.0
      mx = [wp, hp].max
      rv = i.resize((ow/mx).round, (oh/mx).round)
    else
      rv = i
    end
    rv
  end

  def thumbnail_path original_name
    basepath = CartConfig.get(:directory, :image) || File.join(RAILS_ROOT, 'public', 'images', 'products')
    product_path = product.slug
    filepath = "t-#{original_name}"
    File.join(basepath, product_path, filepath)
  end

  def fullsize_path original_name
    basepath = CartConfig.get(:directory, :image) || File.join(RAILS_ROOT, 'public', 'images', 'products')
    product_path = product.slug
    filepath = "#{original_name}"
    File.join(basepath, product_path, filepath)
  end

  def write_file img, path
    FileUtils.mkdir_p File.dirname(path)
    img.write path
  end

end

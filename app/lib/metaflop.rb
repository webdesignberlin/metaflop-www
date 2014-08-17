#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require './app/lib/rack_logger'
require './app/lib/rack_settings'
require './app/lib/font_parameters'
require './app/lib/font_settings'
require './app/lib/web_font'

class Metaflop
  include RackLogger
  include RackSettings

  # args: see FontParameter
  def initialize(args = {})
    @font_settings = FontSettings.new(args)
    @font_parameters = FontParameters.new(args, @font_settings)
  end

  def font_parameters(file = nil)
    if (!@font_parameters_initialized)
      @font_parameters.from_file file
      @font_parameters_initialized = true
    end

    @font_parameters
  end

  def font_settings
    @font_settings
  end

  def font_otf(preview = false)
    @font_settings.cleanup_tmp_dir
    # regenerate from the latest parameters with the sidebearings turned off
    @font_parameters.sidebearing.value = '0'
    font_parameters "#{@font_settings.out_dir}/font.mf"
    @font_parameters.to_file(preview)

    out_file = "#{@font_settings.out_dir}/font.otf"
    settings_parameters = @font_settings.to_hash
    settings_parameters[:timeout] = preview ? 5 : 15
    command = settings[:font_otf] % settings_parameters

    `cd #{@font_settings.out_dir} && rm -f #{out_file} && #{command}`

    @font_parameters.sidebearing.value = nil

    # if something went wrong (e.g. the timeout got triggered) the
    # output file does not exist
    unless File.exist?(out_file)
      raise Error::Metafont.new
    end

    { :name => "#{@font_settings.font_name}.otf",
      :data => File.read(out_file) }
  end

  #  returns base64 encoded otf for embedding as css fontface
  def font_preview
    @font_settings.font_hash = 'preview'
    data = font_otf(true)[:data]
    Base64.strict_encode64(data)
  end

  def font_web
    font_otf
    `cd #{@font_settings.out_dir} && #{settings[:font_web]}`

    font = WebFont.new(@font_settings)
    { :name => "#{font.font_name}_webfont.zip",
      :data => font.zip }
  end

  def self.create(params, settings, logger)
    # map all query params and other options
    args = {}
    (FontParameters::VALID_PARAMETERS_KEYS + FontSettings::VALID_OPTIONS_KEYS).each do |key|
      value = params[key.to_s]

      if value && !value.empty?
        args[key] = value
      end
    end

    mf = Metaflop.new(args)
    mf.settings = settings
    mf.logger = logger

    mf
  end
end

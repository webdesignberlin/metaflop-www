require './metaflop'

# setup the tmp dir where the generated fonts go
tmp_dir = "/tmp/metaflop"
FileUtils.rm_rf(tmp_dir)
Dir.mkdir(tmp_dir)

run Sinatra::Application

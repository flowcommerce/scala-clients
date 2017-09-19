module Util

  @@COUNTER = 0
  @@TMP_DIR = "/tmp/scala.clients"
  if File.exists?(@@TMP_DIR) || File.directory?(@@TMP_DIR)
    `rm -rf #{@@TMP_DIR}`
  end

  def Util.with_tmp_dir(generator_key)
    dir = File.join(@@TMP_DIR, generator_key)
    `mkdir -p #{dir}`
    yield dir
    `rm -rf #{dir}`    
  end

  def Util.with_tmp_file
    path = File.join(@@TMP_DIR, "#{@@COUNTER}.tmp")
    @@COUNTER += 1
    yield path
    `rm #{path}`
  end

end

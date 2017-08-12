module Util

  @@COUNTER = 0
  
  def Util.tmpfile
    "/tmp/scala.clients.#{Process.pid}.tmp"
  end

  def Util.with_tmp_dir
    dir = File.join(Util.tmpfile, @@COUNTER.to_s)
    @@COUNTER += 1
    `mkdir -p #{dir}`
    yield dir
    #`rm -rf #{dir}`    
  end

  def Util.with_tmp_file
    path = File.join(Util.tmpfile, "#{@@COUNTER}.tmp")
    @@COUNTER += 1
    yield path
    #`rm #{path}`
  end

end
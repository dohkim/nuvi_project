module Nuvi
  def extract(zip_files, target_folder)
    Zip::File.open(zip_files) do |zip_file|
      zip_file.each do |f|
        f_path=File.join(target_folder,f.name) 
        f.extract(f_path){true}
      end
    end
  end
  
  def xml_to_redis(redis,xml_path)
    Dir.foreach(xml_path) do |file|
      if file =~ (/\w*.xml/)
        f=File.open("#{xml_path}/#{file}", "r")
        data=f.read
        redis.lpush "NEWS_XML", data
      end
    end
  end
  module_function :extract, :xml_to_redis
end


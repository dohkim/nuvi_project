class Downxml
  attr_reader :lists, :url, :target_folder, :latest
  
  def initialize(url)
    get_url(url)
    get_download_links(url)
  end
  
  def get_url(url)
    @url=Net::HTTP.get_response(URI.parse(url))['location']
  end
  
  def get_download_links(url)
    @lists=[]
    doc = Nokogiri::HTML(open(url))
    doc.css('a').each do |link|
      if link.content.match(/\w*.zip/)
        @lists << link.content
      end
    end
  end
  
  def create_folder(folder_name)
    @target_folder=folder_name
    Dir.mkdir @target_folder unless FileTest.directory? @target_folder
    Dir.mkdir "#{@target_folder}/latest" unless FileTest.directory? "#{@target_folder}/latest"
  end
  
  def new_file_download(path="temp")
    create_folder(path)
    check_latest(@target_folder)
    download_xml(@lists)
  end
  
  def download_xml(lists)
    FileUtils.rm_rf(Dir.glob("./#{target_folder}/*.*"))
    unless lists.empty?
      lists.each do |list|
        file = open(@url+list)
        File.open("#{@target_folder}/#{list}", 'w') do |f| 
          f.write file.read
          p "#{File.basename(f)} is download"
          extract(f, @target_folder)
        end
      end
      update_latest
    else
      p "No update available"
    end
  end
  
  def update_latest
    FileUtils.rm_rf(Dir.glob("./#{target_folder}/latest/*.*"))
    FileUtils.cp "./#{target_folder}/#{@latest}", "./#{target_folder}/latest/#{@latest}"
  end
  
  def check_latest(folder_path)
    @latest=0
    unless Dir["./#{folder_path}/latest/*.zip"].empty?
      @latest=Dir["./#{folder_path}/latest/*.zip"]
      @latest=File.basename(latest[0],".zip").to_i
    end
    @lists=@lists.select do |list|
       File.basename(list,".zip").to_i > @latest
    end
    @latest=@lists.max
  end
  
end
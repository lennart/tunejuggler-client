class Client < RestClient::Resource
  VERBOSE = ENV["VERBOSE"]

  def initialize host, options = {}
    super host 
  end


  def [] *args
    resources = []
    loop do
      resource = args.shift
      if  resource.kind_of?(Symbol) or resource.kind_of?(Fixnum)
        resources << resource.to_s
      else
        break
      end
    end
    super resources.join("/")+".json"
  end

  def search query
    self[:search].post({:query => query})
  end

  def post data, *args
    convert data do |data|
      super data, *args
    end
  end

  def get *args
    convert do 
      super *args
    end
  end

  def put data, *args
    convert data do |data|
      super data, *args
    end
  end

  def delete data, *args
    convert data do |data|
      super data, *args
    end
  end

  private 

  def convert data = nil, &block
    self.class.convert data, &block
  end

  class << self
    def parse result
      log result
      JSON.parse result
    end

    def unparse unencoded
      unless unencoded.kind_of?(String)
        unencoded.to_json
      else
        unencoded
      end
    end

    def convert data = nil
      object = if data
                 object = yield unparse(data)
               else
                 object = yield
               end
      parse object
    end


    def log msg
      if VERBOSE
        puts msg
      end
    end
  end
end

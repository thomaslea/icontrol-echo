require 'rest-client'
require 'rexml/document'

$baseUrl = 'https://beta.icontrol.com'
$loginUrl = "#{$baseUrl}/rest/icontrol/login"

class Icontrol
  def initialize(username, password)
    @username = username
    @password = password
  end

  def login
    puts "logging into icontrol"
    @resource = RestClient::Resource.new( $loginUrl )
    response_login = @resource.get( :'X-AppKey' => "defaultKey", :'X-login' => @username, :'X-password' => @password )
    @sessionId = response_login.cookies["JSESSIONID"]
      
    doc = REXML::Document.new(response_login)
    @site = doc.elements['login/site'].attributes['href']
      
    # Load device maps
    loadLights
    loadDoorLocks
  end

  ###############
  # Lights
  ###############
  def loadLights
    @lights = Hash.new()
    loadDevices("instance/light", @lights)
    puts "Lights: #{@lights}"
  end

  def setAllLights(turnOn)
    @lights.each { |light| setLight(light[0], turnOn) }
  end

  def setLight(name, turnOn)
    url = "#{$baseUrl}#{@lights[name]}/points/isOn?value=#{turnOn}"
    resource = RestClient::Resource.new(url)
    response = resource.post(url, {:cookies => {"JSESSIONID" => @sessionId}})
  end

  ###############
  # Door Locks
  ###############
  def loadDoorLocks
    @doorLocks = Hash.new()
    loadDevices("instance/doorLock", @doorLocks)
    puts "Door Locks: #{@doorLocks}"
  end

  def setAllDoorLocks(lock)
    @doorLocks.each { |doorLock| setDoorLock(doorLock[0], lock) }
  end
  
  def setDoorLock(name, lock)
    #my door lock is named "Front Door" but alexa calls it "front door"
    #can't just pull from map, so instead iterating on keys and on
    # case insensitive match, i change the name to use to match key
    @doorLocks.each do |key, value|
      puts "Key: #{key}, Value: #{value}"
      if (key.casecmp(name) == 0)
        name = key
      end
    end
    puts "putting #{@doorLocks[name]} to state: #{lock}"
    url = "#{$baseUrl}#{@doorLocks[name]}/points/isOn?value=#{lock}"
    resource = RestClient::Resource.new(url)
    response = resource.post(url, {:cookies => {"JSESSIONID" => @sessionId}})
  end

  #################################################
  # Private Stuff
  #################################################
  private
  
  def loadDevices(types, collection)
    response = RestClient.get "#{$baseUrl}#{@site}/network/instances?mediaTypes=#{types}",
    {:cookies => {"JSESSIONID" => @sessionId}}

    doc = REXML::Document.new(response)
    doc.elements.each('instances/instance') do |ele|
      collection[ele.elements['name'].text] =  ele.attributes['href']
    end
  end
end

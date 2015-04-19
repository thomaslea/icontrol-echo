require './helpers'
require_relative './Icontrol'

# "lock my doors stop"

class AlexaIcontrol

# todo in the constructor /initializer init and login with Icontrol class
# use environment varaibles for username/password

  def wake_words
#TODO extend wake words
    ["lock my"]
  end

  def process_command(command)
    puts "Test Process command #{command} "


    if command_present?(command, "lock my")

      parsed_locks = command.gsub("stop", "").split("lock my")[1].chop.strip

      p "locking #{parsed_locks}"

      login = ENV['IC_LOGIN']
      password = ENV['IC_PASSWORD']
      icontrol = Icontrol.new(login, password)
      icontrol.login()

      icontrol.setDoorLock(parsed_locks, "true")

	#TODO call Icontrol class to lock/unlock

    end
  end


end

MODULE_INSTANCES.push(AlexaIcontrol.new)

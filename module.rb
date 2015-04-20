require './helpers'
require_relative './Icontrol'

# "lock my doors stop"

class AlexaIcontrol

  def initialize
	@ic = Icontrol.new(ENV['IC_LOGIN'], ENV['IC_PASSWORD'])
	@ic.login()
  end

  def wake_words
#TODO extend wake words
    ["lock my", "unlock my", "lock all doors"]
  end

  def process_command(command)
    puts "process_command: #{command} "


    if command_present?(command, "lock my")
      parsed_locks = command.gsub("stop", "").split("lock my")[1].chop.strip
      p "locking #{parsed_locks}"
      @ic.setDoorLock(parsed_locks, "true")
    elsif command_present?(command, "unlock my")
      parsed_locks = command.gsub("stop", "").split("unlock my")[1].chop.strip
      p "unlocking #{parsed_locks}"
      @ic.setDoorLock(parsed_locks, "false")
    elsif command_present?(command, "lock all doors")
      p "locking all doors"
      @ic.setAllDoorLocks("true")
    end
  end


end

MODULE_INSTANCES.push(AlexaIcontrol.new)

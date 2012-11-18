class SystemCommand
  # Executes shell command. Returns true if the shell command exits with a success status code
  def self.exec(command)
    logger.debug { "BitbucketPlugin: Executing command: '#{command}'" }

    # Get a path to a temp file
    logfile = Tempfile.new('bitbucket_plugin_exec')
    logfile.close

    success = Kernel.system("#{command} > #{logfile.path} 2>&1")
    output_from_command = File.readlines(logfile.path)
    if success
      logger.debug { "BitbucketPlugin: Command output: #{output_from_command.inspect}"}
    else
      logger.error { "BitbucketPlugin: Command '#{command}' didn't exit properly. Full output: #{output_from_command.inspect}"}
    end

    return success
  ensure
    logfile.unlink unless logfile.nil?
  end
  
  def self.logger
    ::Rails.logger
  end
end
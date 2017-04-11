while true
  commands = File.readlines('./auto_yards.txt').map{ |l| l.strip }
  while commands.length > 0 do
    command = commands.shift
    next unless command.index('open http') == 0

    puts "Running Command: #{command}"
    `#{command}`
    file = File.open('./auto_yards.txt', 'w')
    file << commands.join("\n")
    file.close
    #/usr/bin/pkill --oldest --signal TERM -f chrome
    sleep 5
  end
  puts "No commands, waiting"
  sleep 5
end
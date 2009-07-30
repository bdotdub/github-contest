require 'models'

start_index = ARGV[0].to_i || 0
end_index   = ARGV[1].to_i || 4787
flip        = false

if end_index < start_index
  swap = end_index
  end_index = start_index
  start_index = swap
  flip = true
end

user_ids = []

def time_def(message)
  print "Running: #{message} ... "
  $stdout.flush
  start = Time.now
  yield
  puts "Took #{Time.now - start} seconds"
end

time_def('Load repos')  { Repo.load('input/repos.txt', 'input/lang.txt') }
time_def('Load user')   { User.load('input/data.txt') }

File.open('input/test.txt', 'r').each do |user_id|
  user_ids << user_id.chomp
end

File.open("results.#{start_index}.#{end_index}.txt", 'w') do |f|
  user_ids_to_run = user_ids[start_index..end_index]
  user_ids_to_run.reverse! if flip

  user_ids_to_run.each do |user_id|
    user = User.find(user_id) || User.new(user_id)
    f << "#{user.id}:#{user.recommendations.join(',')}\n"
    f.flush
  end
end


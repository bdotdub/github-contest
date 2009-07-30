$:.unshift 'lib'

require 'file'
require 'user_repos'
require 'match'
require 'intermediate'
require 'pp'

recommendations = IntermediateResult.results
user_repos, repo_users, popular_repos = parse_user_repos('input/data.txt')
test_users = File.lines_for_file('input/test.txt')

trap 'SIGINT' do
  puts "saving intermediate results"
  IntermediateResult.save!
  exit
end

test_users.each do |user|
  if recommendations.key?(user)
    puts "already finished for user #{user}"
    next
  end

  repos     = user_repos[user]
  num_repos = repos.length
  matches   = []
  mrepos     = {}

  puts "on user #{user} with #{repos.length} repos"

  repos.each do |repo|
    other_users = repo_users[repo]
    other_users.each do |other_user|
      next if user == other_user
      num_other_user_repos = user_repos[other_user].length

      intersection = repos & user_repos[other_user]
      intersection_length = intersection.length

      match = Match.new
      match.uid = user
      match.muid = other_user
      match.percentage = intersection_length / num_repos.to_f
      match.mpercentage = intersection_length /  num_other_user_repos.to_f
      match.mrepo_ids = user_repos[other_user] - repos

      match.mrepo_ids.each do |mrepo|
        mrepos[mrepo] ||= 0
        mrepos[mrepo] += match.percentage + match.mpercentage
      end

      matches.push(match)
    end
  end

  top_repos = mrepos.sort{ |a,b| b[1] <=> a[1] }[0,10].map{ |a| a[0] }

  if top_repos.length < 10
    top_repos.concat(popular_repos[top_repos.length..10])
  end
  
  pp top_repos
  recommendations[user] = top_repos
end

File.open('results.txt', 'w+') do |f|
  recommendations.each do |uid, ids|
    f.puts "#{uid}:#{ids.join(',')}"
  end
end


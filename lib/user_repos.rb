def parse_user_repos(file)
  user_repo_map = {}
  repo_user_map = {}
  popular_repos = {}
  
  puts "about to parse user => repo file"
  File.lines_for_file(file).each do |line|
    user, repo = line.split(':')

    user_repo_map[user] ||= []
    user_repo_map[user].push(repo)

    repo_user_map[repo] ||= []
    repo_user_map[repo].push(user)

    popular_repos[repo] ||= 0
    popular_repos[repo] += 1
  end

  puts "done parse user => repo file; sorting most popular"
  popular_repos = popular_repos.sort{ |a, b| b[1] <=> a[1] }[0,10].map{ |a| a[0] }
  puts "done sorting"

  [user_repo_map, repo_user_map, popular_repos]
end


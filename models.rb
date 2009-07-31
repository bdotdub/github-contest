class Repo
  attr_accessor :id, :users, :user_count, :user, :name, :created_at, :fork_id, :languages

  def self.load(repos_file, language_file = nil)
    @@repos = {}
    @@repos_by_language = {}
    @@repos_by_popularity = []

    File.open(repos_file, 'r').each do |line|
      id, the_rest = line.chomp.split(':')
      user_name, created_at, fork_id = the_rest.split(',')
      user, name = user_name.split('/')

      repo = Repo.find(id) || Repo.new(id, user, name, created_at, fork_id)
      @@repos[id] = repo
    end
  end

  def self.find(repo_id)
    @@repos[repo_id]
  end

  def self.top_repos(length)
    if @@repos_by_popularity.nil? or @@repos_by_popularity.empty?
      @@repos_by_popularity = @@repos.values.sort{ |a,b| b.user_count <=> a.user_count }
    end

    @@repos_by_popularity[0,length]
  end

  def initialize(id, user = nil, name = nil, created_at = nil, fork_id = nil)
    @id = id
    @user = user
    @name = name
    @created_at = created_at
    @fork_id = fork_id

    @users = []
    @languages = {}
    @user_count = 0
  end

  def followed_by(user)
    @users << user
    @user_count += 1
  end
end

class User
  attr_accessor :repos
  attr_reader :id

  def self.load(filename)
    @@users = {}

    File.open(filename).each do |line|
      id, repo_id = line.chomp.split(':')
      user = User.find(id) || User.new(id)
      repo = Repo.find(repo_id) || Repo.new(repo_id)

      user.follow(repo)
      @@users[id] = user
    end
  end

  def self.all
    @@users
  end

  def self.find(user_id)
    @@users[user_id]
  end

  def initialize(id)
    @id = id
    @repos = []
  end

  def follow(repo)
    @repos << repo
    repo.followed_by(self)
  end

  def recommendations
    recs = get_ranked_repos
    recs = remove_lower_ranked_forks(recs)
    recs = replace_with_more_popular_parent(recs)

    (recs + Repo.top_repos(10).map{|r| r.id })[0,10]
  end

  def get_ranked_repos
    recs = {}
    my_repo_ids = @repos.map{|r| r.id }
    num_repos = @repos.length
    seen_user_ids = {}

    @repos.each do |repo|
      repo.users.each do |user|
        # next if seen_user_ids.key?(user)
        next if user.id == @id

        their_repo_ids = user.repos.map{|r| r.id }
        their_num_repos = their_repo_ids.length

        # Intersection
        intersection = my_repo_ids & their_repo_ids
        intersection_size = intersection.length
        difference = their_repo_ids - my_repo_ids

        # Percentages
        my_percentage = intersection_size / num_repos.to_f
        their_percentage = intersection_size / their_num_repos.to_f

        # Give points to recommendation
        sum_percentage = my_percentage + their_percentage
        difference.each do |diff|
          recs[diff] ||= 0
          recs[diff] += sum_percentage
        end

        # Mark as seen
        seen_user_ids[user] = 1
      end
    end

    recs.sort{ |a,b| b[1] <=> a[1] }.map{|i| i[0] }[0, 50]
  end

  def remove_lower_ranked_forks(recs)
    seen = {}
    recs.select do |r|
      if seen.key?(Repo.find(r).name)
        false
      else
        seen[Repo.find(r).name] = 1
        true
      end
    end
  end

  def replace_with_more_popular_parent(recs)
    recs.map do |r|
      repo = Repo.find(r)
      fork_repo = Repo.find(repo.fork_id) || Repo.new(repo.fork_id)

      if fork_repo.user_count > repo.user_count and fork_repo.name == repo.name
        fork_repo.id
      else
        repo.id
      end
    end
  end
end


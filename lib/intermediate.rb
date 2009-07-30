require 'yaml'

class IntermediateResult
  def self.setup
    if File.exist?('output/intermediate.txt')
      File.open('output/intermediate.txt', 'r') do |f|
        @@results = YAML.load(f.read)
      end
    else
      @@results = {}
    end
  end

  def self.results
    @@results
  end

  def self.save!
    File.open('output/intermediate.txt', 'w+') do |f|
      f.write(@@results.to_yaml)
    end
  end

  def self.save(time)
    File.open("output/intermediate.#{time}.txt", "w+") do |f|
      f.write(@@results.to_yaml)
    end
  end
end

IntermediateResult.setup


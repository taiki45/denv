require 'fileutils'

name = 'denv_test'
path = File.expand_path(__dir__)

system('bundle install -j8')
FileUtils.rm_rf('tmp')
FileUtils.mkdir_p('tmp')
Dir.chdir('tmp') do
  system("bundle exec rails new #{name} --skip-bundle")
  Dir.chdir(name) do
    lines = File.read('Gemfile').split("\n")
    new = lines.first(1) + [%!gem "denv", path: "#{path}"!] + lines.drop(1)
    File.open('Gemfile', 'w') {|f| f.puts(new.join("\n")) }
    system('bundle install -j8')

    File.open('.env', 'w') {|f| f.puts("XXX=123\nYYY=1\n") }
    result = system(%!bundle exec rails runner 'ENV["XXX"] == "123" ? exit : exit(1)'!)
    if result
      puts "[#{name}] Test case 'default' succeeded"
    else
      $stderr.puts "[#{name}] Test case 'default' failed"
      exit(1)
    end

    File.open('.env.local', 'w') {|f| f.puts("XXX=000\n") }
    result = system(%!bundle exec rails runner 'ENV["XXX"] == "000" ? exit : exit(1)'!)
    if result
      puts "[#{name}] Test case 'overwirte' succeeded"
    else
      $stderr.puts "[#{name}] Test case 'overwirte' failed"
      exit(1)
    end
  end
end

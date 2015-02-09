require 'fileutils'

policy = JSON.parse(File.read('policy.json'))
FileUtils.mkdir_p('hosts')

Dir.chdir 'hosts' do
  policy['api_keys'].keys.select{|k| k.split(':')[1] == 'host'}.each do |host_id|
    id = host_id.split(':')[2]
    name = id.split('/')[-1]
    puts "Generating conjurize for #{name}"
    api_key = policy['api_keys'][host_id]
    fname = "#{name}.json"
    File.write(fname, JSON.pretty_generate({
      id: id,
      api_key: api_key
    }))
    `cat #{fname} | conjurize > conjurize-#{name}.sh`
    FileUtils.chmod 0700, "conjurize-#{name}.sh"
    FileUtils.rm_f fname
  end
end

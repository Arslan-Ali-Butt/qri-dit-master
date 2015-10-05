require 'csv'
namespace :presales do
  desc 'YAML FROM CSV'
  task :go, [:infile, :outfile] => [:environment] do |t,args|
    infile_ok = File.readable?(args[:infile])
    outfile_ok = !File.exists?(args[:outfile]) || File.writable?(args[:outfile])
    puts 'error: bad parameter' if !infile_ok || !outfile_ok
    File.open args[:outfile], "w+" do |file|
      file.write YAML.dump(CSV.read(args[:infile]).map {|row| { name: row[0], email: row[1].try(:downcase) } })
    end if infile_ok && outfile_ok    
  end
end
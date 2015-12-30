require 'yaml'
require 'json'

ProfileStat.all.each do |rec|
  rec.stats_hash_v2 = rec.stats_hash
  begin
    rec.save!
  rescue Exception => e
    "Bailing - #{e.mesg}"
    exit -1
  end
end

  

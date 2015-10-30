class DocumentUniverse < ActiveRecord::Base
  extend TwitterAnalysis
  serialize :universe, TextStats::DocumentUniverse
  
  def self.reanalyze
    du = TextStats::DocumentUniverse.new
    TwitterProfile.all.each do |profile|
      if profile.tweet_packets.size > 0
        du.add TextStats::DocumentModel.new(separated_docs(profile.tweet_packets.all)[:all_doc])
      end
    end
    create universe: du
  end
end

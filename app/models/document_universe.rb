class DocumentUniverse < ActiveRecord::Base
  extend TwitterAnalysis
  serialize :universe, TextStats::DocumentUniverse
  
  def self.reanalyze
    du = TextStats::DocumentUniverse.new
    TweetPacket.pluck(:tweets_list).each do |pkt|
      if pkt and pkt.size > 0
        du.add TextStats::DocumentModel.new(separated_docs(pkt)[:all_doc])
      end
    end
    create universe: du
  end
end

class DocumentUniverse < ActiveRecord::Base
  extend TwitterAnalysis
  serialize :universe, TextStats::DocumentUniverse
  
  def self.reanalyze
    du = TextStats::DocumentUniverse.new
    Tweet.pluck(:mesg).each do |mesg|
      if mesg.present? and mesg.size > 0
        du.add TextStats::DocumentModel.new(mesg)
      end
    end
    create universe: du
  end
end

module Ajax
  class Actions
    def self.perform(idx, opts = {})
      executed = false
      case idx
      when 1
        list = []
        if t = opts[:user]&.email
          Response.update opts[:user].email
          executed = true
        end
      end

      executed
    end    

    def self.valid_ids
      [1, 2, 3]
    end

    def self.last_known_response
      Response.last_known_response
    end
  end
end

module Ajax
  class Actions
    def self.perform(idx)
      true
    end

    def self.valid_ids
      [1]
    end    
  end
  
  class Library
    def self.route_action(action_str)
      status_struct = {status: 'error', code: '500'}
      
      matches = /^(\w+)\/(\w+)\/(.*)/.match(action_str)
      if matches
        controller = matches[1]
        action = matches[2]
        params = matches[3].split '/'                                  
        
        case controller
        when 'reads'
          status_struct = {status: 'success'}
        when 'actions'
          # this is special, to allow for direct multiplexing from here, rather than send to
          # a model in the app
          code = 422
          begin
            if params.size > 0 and (i = params[0].to_i) != '0' and Actions.valid_ids.include?(i)
              success = Actions.perform i
            end
            if success
              code = 200
            end
          rescue Exception => e
            code = '500'
          end
            
          status_struct = {status: success ? 'success' : 'error', code: code, data: 'hello world'}
        end
      end
      
      status_struct
    end
  end
end

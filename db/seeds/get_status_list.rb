last_10 = Status.order(created_at: :desc).limit 10
last_10.each do |stat|
  puts "#{stat.created_at}: (#{stat.source}) #{stat.message}"
end


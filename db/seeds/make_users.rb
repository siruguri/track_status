u = User.find_or_create_by(email: 'user1@trackstatus.com')
u.password='userpass123'
u.confirmed_at = Time.now.utc
u.save

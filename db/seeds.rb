Hoot.delete_all
Friendship.delete_all
Invite.delete_all
User.delete_all

u1 = User.create!(email: "alice@test.com", username: "alice", password: "password123", password_confirmation: "password123", display_name: "Alice")
u2 = User.create!(email: "bob@test.com", username: "bob", password: "password123", password_confirmation: "password123", display_name: "Bob")

f = Friendship.create!(user: u1, friend: u2)

puts "Created users: alice (#{u1.id}), bob (#{u2.id})"
puts "Created friendship: #{f.id}"
puts "Login with alice@test.com / password123 or bob@test.com / password123"

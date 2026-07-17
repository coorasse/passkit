@user1 = User.create!(name: "First User")
@user2 = User.create!(name: "Second User")

Ticket.create!(name: "Ticket1", user: @user1)
Ticket.create!(name: "Ticket2", user: @user1)
Ticket.create!(name: "Ticket3", user: @user2)
User.create!(
  name: "Admin",
  email: "admin@gmail.com",
  password: "12345",
  password_confirmation: "12345",
  birthday: Date.new(1990, 1, 1),
  gender: "male",
  admin: true
)

50.times do |n|
  name = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "12345"
  birthday = Faker::Date.birthday(min_age: 18, max_age: 40)
  gender = %w[male female other].sample

  User.create!(
    name: name,
    email: email,
    password: password,
    password_confirmation: password,
    birthday: birthday,
    gender: gender
  )
end

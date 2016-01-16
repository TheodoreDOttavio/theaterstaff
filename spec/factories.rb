Factory.define :user do |f|
  f.sequence(:email) { |n| "foo #{n}@factoryexample.com"}
  f.password "secret"
end
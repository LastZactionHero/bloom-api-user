FactoryGirl.define do
  factory :user do
    email 'user@site.com'
    password 'mypassword1234'

    account_status 'full_access'
  end
end

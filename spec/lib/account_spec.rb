require "spec_helper"
require "account"

describe Account do

  it "Stores parameters passed in constructor" do
    parameters = {
      name: 'Demo Everyday Account',
      id: '16995',
      currency: 'USD',
      available_balance: '1919.69',
      current_balance: '2069.69',
      transactions: [{
        "date": "2021-06-09",
        "description": "telegraphic transfer fee Foreign TT",
        "amount": 20.0,
        "currency": "USD",
        "account_name": "Demo Everyday Account"
      }]
    }
    account = Account.new(parameters)

    expect(account.name             ).to eq parameters[:name]
    expect(account.id               ).to eq parameters[:id]
    expect(account.currency         ).to eq parameters[:currency]
    expect(account.available_balance).to eq parameters[:available_balance]
    expect(account.current_balance  ).to eq parameters[:current_balance]
    expect(account.transactions     ).to eq parameters[:transactions]

  end

end
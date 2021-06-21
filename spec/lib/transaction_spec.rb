require "spec_helper"
require "transaction"

describe Transaction do

  it "Stores parameters passed in constructor" do
    parameters = {
      date: '2021-06-09',
      description: 'foreign carded telegraphic transfer 63749',
      amount: 100,
      currency: 'USD',
      account_name: 'Demo Everyday Account'
    }
    transaction = Transaction.new(parameters)

    expect(transaction.date        ).to eq parameters[:date]
    expect(transaction.description ).to eq parameters[:description]
    expect(transaction.amount      ).to eq parameters[:amount]
    expect(transaction.currency    ).to eq parameters[:currency]
    expect(transaction.account_name).to eq parameters[:account_name]
  end

end
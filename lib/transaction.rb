require 'json'

class Transaction

  attr_accessor :date, :description, :amount, :currency, :account_name
  
  def initialize(parameters)
  	@date = parameters[:date]
    @description = parameters[:description]
    @amount = parameters[:amount]
    @currency = parameters[:currency]
    @account_name = parameters[:account_name]
  end

  def to_json(*a)
    {
      date: @date,
      description: @description,
      amount: @amount,
      currency: @currency,
      account_name: @account_name
    }.to_json(*a)
  end

end

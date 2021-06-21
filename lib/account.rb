class Account

attr_accessor :name, :id, :currency, :available_balance, :current_balance, :transactions
 
  def initialize(parameters)
    @name = parameters[:name]
    @id = parameters[:id]
    @currency = parameters[:currency]
    @available_balance = parameters[:available_balance]
    @current_balance = parameters[:current_balance]
    @transactions = parameters[:transactions]
  end

  def to_json(*a)
    {
      name: @name,
      id: @id,
      currency: @currency,
      available_balance: @available_balance,
      current_balance: @current_balance,
      transactions: @transactions
    }.to_json(*a)
  end
end
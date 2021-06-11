require "bendigobank"
require "spec_helper"


describe "BendigoBank" do

  before (:all) do
    @bank =  BendigoBank.new
  end

  it "can parse accounts" do    
    html = File.open(File.dirname(__FILE__) + '/../fixtures/01_get_accounts_id.html')
    accounts = @bank.get_accounts_id(html)
    expect(accounts.size).to be 5
    expect(accounts).to be_kind_of(Array)
  end

  it "can parse account" do
    account_html = File.open(File.dirname(__FILE__) + '/../fixtures/02_get_account_info.html')
    account = @bank.parse_account(account_html)
    expect(account).to be_kind_of(Array)
    expect(account.size).to  be  3
  end

  it "can get transactions links" do
    transactions_html = File.open(File.dirname(__FILE__) + '/../fixtures/03_02_get_transactions_id.html')
    account = @bank.get_links_account_transactions(transactions_html)
    expect(account).to be_kind_of(Array)
    expect(account.size).to  be  > 0
  end

  it "dont can get transactions links" do
    transactions_html = File.open(File.dirname(__FILE__) + '/../fixtures/03_01_get_transactions_id_if_no_transactions.html')
    account = @bank.get_links_account_transactions(transactions_html)
    expect(account).to be_kind_of(Array)
    expect(account.size).to  be   0
  end

  it " can parse transaction" do
    transaction_html = File.open(File.dirname(__FILE__) + '/../fixtures/04_transaction_info.html')
    account = @bank.parse_transaction(transaction_html)
    expect(account).to be_kind_of(Array)
    expect(account.size).to  be   4
  end

  it "can parsing current balance" do
    expect(@bank.parsing_current_balance "$99,999.01").to be_kind_of Float
    expect(@bank.parsing_current_balance "99,99.01").to eq 9999.01
    expect(@bank.parsing_current_balance "Minus − $264,321.80"). to eq -264321.80
  end

  it "can get currency" do
    expect(@bank.get_currency "$99,99.01").to eq "USD"
    expect(@bank.get_currency "99,99.01").to eq "not USD"
  end    

  it " can parse currency and available balance" do
    examlpe = '$99,999.01'
    expect(@bank.parsing_currency_and_available_balance examlpe).to be_kind_of Array
    expect(@bank.parsing_currency_and_available_balance examlpe).to  eq  ["USD", 99999.01]
    expect(@bank.parsing_currency_and_available_balance 'Rub9923,23.06').to  eq  ["not USD", 992323.06]
  end


end